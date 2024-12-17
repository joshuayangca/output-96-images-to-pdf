#!/bin/bash

# Combine the Python script and shell script in one executable

# Create a temporary Python script
temp_python_script="$(mktemp)"
cat << 'EOF' > "$temp_python_script"
import sys
import warnings
import cv2
import os
import numpy as np
from reportlab.pdfgen import canvas
import re

warnings.filterwarnings('ignore')

def natural_sort(files):
    """
    Sort filenames in a natural order (handling numbers correctly).
    """
    def sort_key(file_name):
        return [int(text) if text.isdigit() else text.lower() for text in re.split('([0-9]+)', file_name)]

    return sorted(files, key=sort_key)

def images_to_pdf_fixed_size(image_files, output_pdf, rows=8, cols=12, cell_size=(1224, 904), cell_padding=10):
    """
    Combines images into a grid format (rows x columns) on a single-page PDF, optimized for images with fixed dimensions using OpenCV.
    Labels each image with its filename, aligned to the upper-left corner, with white text.
    """
    if not image_files:
        print("No images found in the specified list.")
        return

    cell_width = cell_size[0] + cell_padding
    cell_height = cell_size[1] + cell_padding

    page_width = cols * cell_width
    page_height = rows * cell_height

    page = np.ones((page_height, page_width, 3), dtype=np.uint8) * 255

    for index, image_path in enumerate(image_files[:rows * cols]):
        print(f"Processing: {image_path}")
        img = cv2.imread(image_path)

        img = cv2.resize(img, (cell_size[0], cell_size[1]))

        row = index // cols
        col = index % cols
        x = col * cell_width + cell_padding // 2
        y = row * cell_height + cell_padding // 2

        page[y:y+cell_size[1], x:x+cell_size[0]] = img

        filename = os.path.basename(image_path)
        font_scale = 3
        font_thickness = 3
        text_size, _ = cv2.getTextSize(filename, cv2.FONT_HERSHEY_SIMPLEX, font_scale, font_thickness)
        text_width, text_height = text_size

        cv2.putText(page, filename, (x + 10, y + text_height + 10), 
                    cv2.FONT_HERSHEY_SIMPLEX, font_scale, (255, 255, 255), font_thickness)

    temp_image_path = "temp_image.png"
    cv2.imwrite(temp_image_path, page)

    c = canvas.Canvas(output_pdf, pagesize=(page_width, page_height))
    c.drawImage(temp_image_path, 0, 0, width=page_width, height=page_height)
    c.save()

    os.remove(temp_image_path)

    print(f"PDF created successfully: {output_pdf}")

def filter_and_create_pdfs(image_folder, output_pdf_gfp, output_pdf_dapi):
    image_files = natural_sort([os.path.join(image_folder, file) for file in os.listdir(image_folder)
                   if file.lower().endswith(('png', 'jpg', 'jpeg', 'bmp', 'tif'))])

    gfp_images = [file for file in image_files if 'GFP' in file.upper()]
    dapi_images = [file for file in image_files if 'DAPI' in file.upper()]

    images_to_pdf_fixed_size(gfp_images, output_pdf_gfp)
    images_to_pdf_fixed_size(dapi_images, output_pdf_dapi)

if __name__ == "__main__":
    input_directory = sys.argv[1]

    output_pdf_gfp = os.path.join(input_directory, "GFP_images.pdf")
    output_pdf_dapi = os.path.join(input_directory, "DAPI_images.pdf")

    filter_and_create_pdfs(input_directory, output_pdf_gfp, output_pdf_dapi)
EOF

# Run the temporary Python script
python3 "$temp_python_script" "$(dirname "$0")"

# Cleanup the temporary Python script
rm "$temp_python_script"
