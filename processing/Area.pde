public class Area {
    private float x;
    private float y;
    private float contentWidth;
    private float contentHeight;
    private float areaWidth;
    private float areaHeight;
    private color background;
    private Margin margin;
    
    Area(float x, float y, float areaWidth, float areaHeight, color background, Margin margin) {
        this.margin = margin;
        this.x = x + this.margin.getLeft();
        this.y = y + this.margin.getTop();
        this.areaWidth = areaWidth;
        this.areaHeight = areaHeight;
        this.contentWidth = this.areaWidth - (this.margin.getLeft() + this.margin.getRight());
        this.contentHeight = this.areaHeight - (this.margin.getTop() + this.margin.getBottom());
        this.background = background;
    }
    
    public float getX() {
        return this.x;
    }
    
    public float getY() {
        return this.y;
    }
    
    public float getContentWidth() {
        return this.contentWidth;
    }
    
    public float getContentHeight() {
        return this.contentHeight;
    }
    
    public float getAreaHeight() {
        return this.areaHeight;
    }
    
    public float getAreaWidth() {
        return this.areaWidth;
    }
    
    public color getBackground() {
        return this.background;
    }
    
    public Margin getMargin() {
        return this.margin;
    }
}