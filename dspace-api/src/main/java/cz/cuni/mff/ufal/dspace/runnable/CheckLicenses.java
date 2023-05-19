package cz.cuni.mff.ufal.dspace.runnable;

import cz.cuni.mff.ufal.DSpaceApi;
import cz.cuni.mff.ufal.lindat.utilities.HibernateFunctionalityManager;
import cz.cuni.mff.ufal.lindat.utilities.hibernate.LicenseResourceMapping;
import cz.cuni.mff.ufal.lindat.utilities.interfaces.IFunctionalities;
import org.dspace.content.*;
import org.dspace.core.Constants;
import org.dspace.core.Context;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

public class CheckLicenses {
    static private IFunctionalities f = DSpaceApi.getFunctionalityManager();
    static private Context ctx = null;

    public static void main(String[] args){
        f.openSession();
        try {
            ctx = new Context();
            ctx.turnOffAuthorisationSystem();
            ItemIterator items = Item.findAll(ctx);
            while (items.hasNext()) {
                Item item = items.next();
                checkMetadataAndDatabaseMatch(item);
            }
            checkUnexpectedAnonymousConfirmation();
            ctx.restoreAuthSystemState();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }finally {
            f.closeSession();
            if (ctx != null) {
                ctx.abort();
            }
        }
    }

    private static void checkUnexpectedAnonymousConfirmation() throws SQLException {
        HibernateFunctionalityManager hf = (HibernateFunctionalityManager)f;
        List<Integer> bitstreamIdsOfAskOnlyOnceWhereConfirmedByAnonymous = hf.getBitstreamIdsOfAskOnlyOnceWhereConfirmedByAnonymous();

        HashSet<Item> items = new HashSet<Item>();
        for(int bitstream_id : bitstreamIdsOfAskOnlyOnceWhereConfirmedByAnonymous){
            Bitstream b =  Bitstream.find(ctx, bitstream_id);
            if(b == null){
                System.out.println("ERR: Bitstream " + bitstream_id + " not found");
            }else{
                DSpaceObject parentObject = b.getParentObject();
                if(parentObject.getType() == Constants.ITEM) {
                    items.add((Item) parentObject);
                }
            }
        }
        for(Item i :items){
            System.out.println("ERR: Item " + i.getID() + " has unexpected anonymous confirmation");
        }
    }

    private static void checkMetadataAndDatabaseMatch(Item item) throws SQLException {
        if(item.hasUploadedFiles()){
            Metadatum[] mds = item.getMetadataByMetadataString("dc.rights.uri");
            if(mds.length != 1){
                System.out.println("ERR: Item " + item.getID() + " has " + mds.length + " dc.rights.uri");
            }else{
                String uri = mds[0].value;
                // this should be fine we've checked hasUploadedFiles
                Bitstream b = item.getNonInternalBitstreams()[0];
                List<LicenseResourceMapping> mappings = f.getAllMappings(b.getID());
                for(LicenseResourceMapping mapping : mappings){
                    if(mapping.isActive()){
                        if(!uri.equals(mapping.getLicenseDefinition().getDefinition())){
                            System.out.println("ERR: Item " + item.getID() + " has dc.rights.uri " + uri + " " +
                                    "but database has " + mapping.getLicenseDefinition().getDefinition());
                        }
                    }
                }
            }
        }
    }
}
