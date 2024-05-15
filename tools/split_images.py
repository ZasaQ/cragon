from pathlib import Path
import random
import os
import sys

image_path = '/content/images/all'
train_path = '/content/images/train'
val_path   = '/content/images/validation'
test_path  = '/content/images/test'

jpeg_file_list = [path for path in Path(image_path).rglob('*.jpeg')]
jpg_file_list  = [path for path in Path(image_path).rglob('*.jpg')]
png_file_list  = [path for path in Path(image_path).rglob('*.png')]
bmp_file_list  = [path for path in Path(image_path).rglob('*.bmp')]

if sys.platform == 'linux':
    JPEG_file_list = [path for path in Path(image_path).rglob('*.JPEG')]
    JPG_file_list = [path for path in Path(image_path).rglob('*.JPG')]
    file_list = jpg_file_list + JPG_file_list + png_file_list + bmp_file_list + JPEG_file_list + jpeg_file_list
else:
    file_list = jpg_file_list + png_file_list + bmp_file_list + jpeg_file_list

file_num = len(file_list)
print('Total images: %d' % file_num)

train_percentage = 0.8
val_percentage   = 0.1

train_num = int(file_num * train_percentage)
val_num   = int(file_num * val_percentage)
test_num  = file_num - train_num - val_num

print(f'Images moving to train: {train_num}')
print(f'Images moving to validation: {val_num}')
print(f'Images moving to test: {test_num}')

# 80% as train data
for i in range(train_num):
    move_me     = random.choice(file_list)
    fn          = move_me.name
    base_fn     = move_me.stem
    parent_path = move_me.parent
    xml_fn      = base_fn + '.xml'
    os.rename(move_me, train_path+'/'+fn)
    os.rename(os.path.join(parent_path,xml_fn), os.path.join(train_path,xml_fn))
    file_list.remove(move_me)

# 10% as validation data
for i in range(val_num):
    move_me     = random.choice(file_list)
    fn          = move_me.name
    base_fn     = move_me.stem
    parent_path = move_me.parent
    xml_fn      = base_fn + '.xml'
    os.rename(move_me, val_path+'/'+fn)
    os.rename(os.path.join(parent_path,xml_fn), os.path.join(val_path,xml_fn))
    file_list.remove(move_me)

# 10% as test data
for i in range(test_num):
    move_me     = random.choice(file_list)
    fn          = move_me.name
    base_fn     = move_me.stem
    parent_path = move_me.parent
    xml_fn      = base_fn + '.xml'
    os.rename(move_me, test_path+'/'+fn)
    os.rename(os.path.join(parent_path,xml_fn), os.path.join(test_path,xml_fn))
    file_list.remove(move_me)