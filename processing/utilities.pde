float textBase(String yAlignment) {
    float asc = textAscent();
    float dsc = textDescent();
    float textHeight = asc + dsc;
    float scalar = 0;
    
    if (yAlignment == "top") {
        scalar = -0.259;
    } else if (yAlignment == "center") {
        scalar = -0.124;
    } else if (yAlignment == "bottom") {
        scalar = 0.2155;
    } 
    return textHeight * scalar; 
}

String getCurrentTime() {
    return nf(hour(), 2) + " : " + nf(minute(), 2) + " : " + nf(second(), 2);
}

String getCurrentDate() {
    return new SimpleDateFormat("EEE, MMM d,yyyy").format(new Date());
}