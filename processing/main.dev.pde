
    if (iAngle == 359) {
        iAngle = 0;
    }
    iAngle++;
    iDistance = (int) random(10000);;
    if (iDistance <= maxDistance) {
        lastDistance = iDistance;
        lastAngle = iAngle;
        
        if (objects.size() > 6) {
            objects.remove(0);
        }
        objectsCount++;
        objects.add(new Object(iDistance, iAngle, getCurrentTime(), getCurrentDate()));
        
        
        if (iDistance >= 100 && !far.isPlaying()) {
            near.pause();
            far.rewind();
            far.play();
        }
        
        if (iDistance < 100 && !near.isPlaying()) {
            far.pause();
            near.rewind();
            near.play();
        }
    }
    
    