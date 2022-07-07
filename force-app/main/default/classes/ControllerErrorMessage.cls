public class ControllerErrorMessage {
    private String error;
    private String message;
    private String title;
    
    public ControllerErrorMessage(String error, String message) {
        this.error = error;
        this.message = message;
    }

    public ControllerErrorMessage(String error, String message, String title) {
        this.error = error;
        this.message = message;
        this.title = title;
    }
    
    public String GetJson() {
        return JSON.serialize(this);
    }
}