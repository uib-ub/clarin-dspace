package cz.cuni.mff.ufal.dspace.app.xmlui.aspect.submission.submit;

import cz.cuni.mff.ufal.Logger;
import org.dspace.app.xmlui.aspect.submission.AbstractSubmissionStep;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.*;
import org.dspace.content.Item;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.sql.SQLException;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

public class NarratorStep extends AbstractSubmissionStep {

    org.apache.log4j.Logger log = Logger.getLogger(NarratorStep.class);

    protected static final Message T_head =
            message("xmlui.Submission.submit.NarratorStep.head");
    protected static final Message T_new_narrator =
            message("xmlui.Submission.submit.NarratorStep.new_narrator");
    protected static final Message T_title_help =
            message("xmlui.Submission.submit.NarratorStep.title_help");
    protected static final Message T_title_label =
            message("xmlui.Submission.submit.NarratorStep.title_label");
    protected static final Message T_title_missing =
            message("xmlui.Submission.submit.NarratorStep.title_missing");
    protected static final Message T_select_help =
            message("xmlui.Submission.submit.NarratorStep.select_help");
    protected static final Message T_select_label =
            message("xmlui.Submission.submit.NarratorStep.select_label");

    public NarratorStep()
    {
        requireSubmission = true;
        requireStep = true;
    }

    @Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException, SQLException, AuthorizeException, IOException {
        super.addPageMeta(pageMeta);
        pageMeta.addMetadata("include-library", "select2");
    }

    @Override
    public void addBody(Body body) throws SAXException, WingException, UIException, SQLException,IOException, AuthorizeException
    {
        Item item = submission.getItem();
        Collection collection = submission.getCollection();
        String actionURL = contextPath + "/handle/" + collection.getHandle() + "/submit/" + knot.getId() + ".continue";

        Division div = body.addInteractiveDivision("submit-narrator", actionURL, Division.METHOD_POST, "primary submission");
        div.setHead(T_submission_head);
        addSubmissionProgressList(div);

        List form = div.addList("submit-narrator", List.TYPE_FORM);
        form.setHead(T_head);

        String title = item.getMetadata("dc.title");
        Text textTitle = form.addItem().addText("submit-title");
        textTitle.setLabel(T_title_label);
        textTitle.setHelp(T_title_help);
        if(isNotBlank(title)){
           textTitle.setValue(title);
        }
        if(this.errorFields.contains("submit-title")){
            textTitle.addError(T_title_missing);
        }


        Select select = form.addItem().addSelect("submit-narrator-select", "select2");
        select.setLabel(T_select_label);
        select.setHelp(T_select_help);
        select.addOption(-1, T_new_narrator);

        String selected = item.getMetadata("viadat.narrator.identifier");

        String query = "select min(f.resource_id) as resource_id, f.text_value as id, s.text_value as name from metadatavalue f join metadatavalue s" +
                " on f.resource_id = s.resource_id and f.resource_type_id = s.resource_type_id and f.metadata_field_id = ? and s.metadata_field_id = ? group by f.text_value, s.text_value;";
        MetadataSchema schema = MetadataSchema.find(context, "viadat");

        TableRowIterator tri = DatabaseManager.query(context, query, MetadataField.findByElement(context, schema.getSchemaID(), "narrator", "identifier").getFieldID(), MetadataField.findByElement(context, schema.getSchemaID(), "narrator", "name").getFieldID());
        while(tri.hasNext()){
            TableRow row = tri.next(context);
            int resource_id = row.getIntColumn("resource_id");
            String identifier = row.getStringColumn("id");
            String name = row.getStringColumn("name");
            select.addOption(identifier.equals(selected), resource_id, name + " - " + identifier);
        }

        addControlButtons(form);

    }

    @Override
    public List addReviewSection(List reviewList) throws SAXException, WingException, UIException, SQLException, IOException, AuthorizeException {
        return null;
    }
}
