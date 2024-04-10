import base64


def convert_file_to_binary(file_path):
    with open(file_path, "rb") as target_file:
        encoded_image = base64.b64encode(target_file.read()).decode('utf-8')
    return encoded_image