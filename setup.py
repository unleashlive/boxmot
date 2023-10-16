from setuptools import find_packages, setup

setup(
    name='boxmot',  # name of pypi package
    version='10.0.45.0',  # version of pypi package
    python_requires='>=3.8',
    license='AGPL-3.0',
    description=('SOTA tracking methods for detection, segmentation and pose estimation models.'),
    long_description_content_type='text/markdown',
    url='https://github.com/mikel-brostrom/yolov8_tracking',
    project_urls={
        'Bug Reports': 'https://github.com/mikel-brostrom/yolo_tracking/issues',
        'Source': 'https://github.com/mikel-brostrom/yolo_tracking'},
    author='Mikel Brostrom',
    author_email='yolov5.deepsort.pytorch@gmail.com',
    packages=find_packages(),  # required
    include_package_data=True,
    install_requires=[],
    platforms=["linux"]
)
