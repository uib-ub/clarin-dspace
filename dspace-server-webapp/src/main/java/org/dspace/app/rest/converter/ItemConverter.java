/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.converter;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Logger;
import org.dspace.app.rest.model.ItemRest;
import org.dspace.app.rest.model.MetadataValueList;
import org.dspace.app.rest.projection.Projection;
import org.dspace.app.rest.utils.ContextUtil;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataValue;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.clarin.ClarinItemService;
import org.dspace.core.Context;
import org.dspace.discovery.IndexableObject;
import org.dspace.services.model.Request;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

/**
 * This is the converter from/to the Item in the DSpace API data model and the
 * REST data model
 *
 * @author Andrea Bollini (andrea.bollini at 4science.it)
 */
@Component
public class ItemConverter
        extends DSpaceObjectConverter<Item, ItemRest>
        implements IndexableObjectConverter<Item, ItemRest> {

    @Autowired
    private ItemService itemService;

    @Autowired
    private ClarinItemService clarinItemService;

    private static final Logger log = org.apache.logging.log4j.LogManager.getLogger(ItemConverter.class);

    @Override
    public ItemRest convert(Item obj, Projection projection) {
        Context context = null;
        Request currentRequest = requestService.getCurrentRequest();
        if (currentRequest != null) {
            context = ContextUtil.obtainContext(currentRequest.getHttpServletRequest());
        }
        try {
            clarinItemService.updateItemDatesMetadata(context, obj);
        } catch (SQLException e) {
            log.error("Error updating item dates metadata", e);
            throw new RuntimeException(e);
        }

        ItemRest item = super.convert(obj, projection);
        item.setInArchive(obj.isArchived());
        item.setDiscoverable(obj.isDiscoverable());
        item.setWithdrawn(obj.isWithdrawn());
        item.setLastModified(obj.getLastModified());

        List<MetadataValue> entityTypes =
            itemService.getMetadata(obj, "dspace", "entity", "type", Item.ANY, false);
        if (CollectionUtils.isNotEmpty(entityTypes) && StringUtils.isNotBlank(entityTypes.get(0).getValue())) {
            item.setEntityType(entityTypes.get(0).getValue());
        }

        return item;
    }

    /**
     * Retrieves the metadata list filtered according to the hidden metadata configuration
     * When the context is null, it will return the metadatalist as for an anonymous user
     * Overrides the parent method to include virtual metadata
     * @param context The context
     * @param obj     The object of which the filtered metadata will be retrieved
     * @return A list of object metadata (including virtual metadata) filtered based on the hidden metadata
     * configuration
     */
    @Override
    public MetadataValueList getPermissionFilteredMetadata(Context context, Item obj) {
        List<MetadataValue> fullList = itemService.getMetadata(obj, Item.ANY, Item.ANY, Item.ANY, Item.ANY, true);
        List<MetadataValue> returnList = new LinkedList<>();
        try {
            if (obj.isWithdrawn() && (Objects.isNull(context) ||
                                      Objects.isNull(context.getCurrentUser()) || !authorizeService.isAdmin(context)) &&
                    ObjectUtils.isEmpty(itemService.getMetadataByMetadataString(obj, "local.withdrawn.reason"))) {
                // if the item is withdrawn and is replaced the item could have a tombstone -
                // return message for the tombstone
                List<MetadataValue> isReplacedBy =
                        itemService.getMetadataByMetadataString(obj, "dc.relation.isreplacedby");
                if (!ObjectUtils.isEmpty(isReplacedBy)) {
                    ArrayList<MetadataValue> allowedMetadataValues = new ArrayList<>();
                    allowedMetadataValues.addAll(isReplacedBy);
                    // Add authors to the tombstone
                    allowedMetadataValues.addAll(
                            itemService.getMetadataByMetadataString(obj, "dc.contributor.author"));
                    allowedMetadataValues.addAll(
                            itemService.getMetadataByMetadataString(obj, "dc.contributor.other"));
                    return new MetadataValueList(allowedMetadataValues);
                } else {
                    return new MetadataValueList(new ArrayList<MetadataValue>());
                }
            }
            if (context != null && (authorizeService.isAdmin(context) || itemService.canEdit(context, obj))) {
                return new MetadataValueList(fullList);
            }
            for (MetadataValue mv : fullList) {
                MetadataField metadataField = mv.getMetadataField();
                if (!metadataExposureService
                        .isHidden(context, metadataField.getMetadataSchema().getName(),
                                  metadataField.getElement(),
                                  metadataField.getQualifier(), obj)) {
                    returnList.add(mv);
                }
            }
        } catch (SQLException e) {
            log.error("Error filtering item metadata based on permissions", e);
        }
        return new MetadataValueList(returnList);
    }

    @Override
    protected ItemRest newInstance() {
        return new ItemRest();
    }

    @Override
    public Class<Item> getModelClass() {
        return Item.class;
    }

    @Override
    public boolean supportsModel(IndexableObject idxo) {
        return idxo.getIndexedObject() instanceof Item;
    }
}
