"""
Minimal training scaffold. Use this once you have collected labeled images under a directory:
sulatin_dataset/
  KA/
    sample1.png
    ...
  PA/
    ...
Run:
  python backend/train_baybayin.py --data-dir sulatin_dataset --epochs 10 --output baybayin_model
"""
import argparse
import tensorflow as tf
from tensorflow.keras import layers, models
import os

def build_small_cnn(input_shape=(128,128,1), num_classes=20):
    inputs = tf.keras.Input(shape=input_shape)
    x = layers.Conv2D(32, 3, activation='relu', padding='same')(inputs)
    x = layers.MaxPool2D(2)(x)
    x = layers.Conv2D(64, 3, activation='relu', padding='same')(x)
    x = layers.MaxPool2D(2)(x)
    x = layers.Conv2D(128, 3, activation='relu', padding='same')(x)
    x = layers.MaxPool2D(2)(x)
    x = layers.Flatten()(x)
    x = layers.Dense(256, activation='relu')(x)
    x = layers.Dropout(0.4)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    return models.Model(inputs=inputs, outputs=outputs)

def main(args):
    train_ds = tf.keras.preprocessing.image_dataset_from_directory(
        args.data_dir,
        labels='inferred',
        label_mode='int',
        batch_size=args.batch,
        image_size=(128,128),
        color_mode='grayscale',
        validation_split=0.2,
        subset='training',
        seed=123)
    val_ds = tf.keras.preprocessing.image_dataset_from_directory(
        args.data_dir,
        labels='inferred',
        label_mode='int',
        batch_size=args.batch,
        image_size=(128,128),
        color_mode='grayscale',
        validation_split=0.2,
        subset='validation',
        seed=123)
    classes = train_ds.class_names
    normalization = layers.Rescaling(1./255)
    train_ds = train_ds.map(lambda x,y: (normalization(x), y))
    val_ds = val_ds.map(lambda x,y: (normalization(x), y))

    model = build_small_cnn(input_shape=(128,128,1), num_classes=len(classes))
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    model.fit(train_ds, validation_data=val_ds, epochs=args.epochs)
    model.save(args.output)
    with open(args.output + "_classes.txt", "w", encoding="utf-8") as f:
        for c in classes:
            f.write(c + "\n")
    print("Saved model to", args.output)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", required=True)
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--batch", type=int, default=32)
    parser.add_argument("--output", default="baybayin_model")
    args = parser.parse_args()
    main(args)