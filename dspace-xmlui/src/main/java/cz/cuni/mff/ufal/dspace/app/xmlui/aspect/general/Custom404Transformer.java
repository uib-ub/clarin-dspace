package cz.cuni.mff.ufal.dspace.app.xmlui.aspect.general;

import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.environment.http.HttpEnvironment;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.authorize.AuthorizeException;
import org.xml.sax.SAXException;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Created by okosarko on 11.10.16.
 */
public class Custom404Transformer extends AbstractDSpaceTransformer {

    private static final Message defaultMessage = message("xmlui.Custom404Transformer.default_error");

    private static final Message T_head =
            message("xmlui.PageNotFound.head");

    private static final Message T_title =
            message("xmlui.PageNotFound.title");

    private static final Message T_dspace_home =
            message("xmlui.general.dspace_home");

    @Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException
    {
            // Set the page title
            pageMeta.addMetadata("title").addContent(T_title);

            // Give theme a base trail
            pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
    }

    @Override
    public void addBody(Body body)throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException, ProcessingException{

        String message_key = parameters.getParameter("message_key", null);
        String message_param = parameters.getParameter("message_param", null);

        Message message;
        if(message_key == null){
           message = defaultMessage;
        }else if(message_param == null){
            message = message(message_key);
        }else{
            message = message(message_key).parameterize(message_param);
        }

        Division notFound = body.addDivision("page-not-found","alert alert-error");
        notFound.setHead(T_head);
        notFound.addPara(message);

        HttpServletResponse httpResponse = (HttpServletResponse) objectModel.get(HttpEnvironment.HTTP_RESPONSE_OBJECT);
        httpResponse.setStatus(HttpServletResponse.SC_NOT_FOUND);
    }

}
