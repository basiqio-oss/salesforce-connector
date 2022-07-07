@isTest
public class ControllerErrorMessageTest {
    @isTest
    public static void testGetJson() {
        ControllerErrorMessage err = new ControllerErrorMessage('error', 'message');
        System.assertEquals('{"title":null,"message":"message","error":"error"}', err.GetJson());
    }

    @isTest
    public static void testGetJson_WithTitle() {
        ControllerErrorMessage err = new ControllerErrorMessage('error', 'message', 'title');
        System.assertEquals('{"title":"title","message":"message","error":"error"}', err.GetJson());
    }
}