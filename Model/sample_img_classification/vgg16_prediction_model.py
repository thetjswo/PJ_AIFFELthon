# vgg16_prediction_model.py

# import libraries
from tensorflow.keras.applications.vgg16 import preprocess_input
import tensorflow as tf
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.imagenet_utils import decode_predictions

# make vgg15.h5
import vgg16_download

# img path
IMG_PATH = '../../../Model/sample_img_classification/sample_data/cat_224x224.jpg'

# model path
MODEL_PATH = '../../../Model/sample_img_classification/vgg16.keras'

async def prediction_model() :
    
    model = tf.keras.models.load_model(MODEL_PATH)
    
    img = Image.open(IMG_PATH)
    
    # resize
    target_size = 224
    img = img.resize((target_size, target_size))
    
    # to np array
    np_img = image.img_to_array(img)
    
    # transform to 4 dims
    img_batch = np.expand_dims(np_img, axis=0)
    # feature normalization
    pre_processed = preprocess_input(img_batch)
    
    # predict
    y_preds = model.predict(pre_processed)
    np.set_printoptions(suppress=True, precision=5) # to decimal point 5
    
    # return prediction no.1 
    result = decode_predictions(y_preds, top=1)
    result = {"predicted_label" : str(result[0][0][1]),
              "prediction_score" : str(result[0][0][2])}
    return result