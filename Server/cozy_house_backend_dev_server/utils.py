import base64


def read_image_file(file_path):
    with open(file_path, "rb") as image_file:
        encoded_image = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_image