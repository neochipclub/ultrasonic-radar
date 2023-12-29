public class Margin {
    private float top;
    private float right;
    private float bottom;
    private float left;
    
    Margin(float top, float right, float bottom, float left) {
        this.top = top;
        this.right = right;
        this.bottom = bottom;
        this.left = left;
    }
    
    public float getTop() {return this.top;}
    public float getRight() {return this.right;}
    public float getBottom() {return this.bottom;}
    public float getLeft() {return this.left;}
}