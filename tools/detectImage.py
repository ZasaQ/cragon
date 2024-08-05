import os
import cv2
import numpy as np
import sys
import json
from tensorflow.lite.python.interpreter import Interpreter

def load_labels(lblpath):
    with open(lblpath, 'r') as f:
        return [line.strip() for line in f.readlines()]

def tflite_detect_images(modelpath, imgpath, lblpath):
    labels = load_labels(lblpath)
    interpreter = Interpreter(model_path=modelpath)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    height = input_details[0]['shape'][1]
    width = input_details[0]['shape'][2]
    input_mean = 127.5
    input_std = 127.5

    image = cv2.imread(imgpath)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    imH, imW, _ = image.shape
    image_resized = cv2.resize(image_rgb, (width, height))
    input_data = np.expand_dims(image_resized, axis=0)
    input_data = (np.float32(input_data) - input_mean) / input_std

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()

    boxes = interpreter.get_tensor(output_details[1]['index'])[0]
    classes = interpreter.get_tensor(output_details[3]['index'])[0]
    scores = interpreter.get_tensor(output_details[0]['index'])[0]

    return {"classes": classes.tolist(), "scores": scores.tolist()}

if __name__ == "__main__":
    modelpath = sys.argv[1]
    imgpath = sys.argv[2]
    lblpath = sys.argv[3]
    result = tflite_detect_images(modelpath, imgpath, lblpath)
    print(json.dumps(result))