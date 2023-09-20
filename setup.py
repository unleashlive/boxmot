from pathlib import Path
import pkg_resources as pkg
from setuptools import find_packages, setup

# Settings
FILE = Path(__file__).resolve()
PARENT = FILE.parent  # root directory
README = (PARENT / 'README.md').read_text(encoding='utf-8')
REQUIREMENTS = [f'{x.name}{x.specifier}' for x in pkg.parse_requirements((PARENT / 'requirements.txt').read_text())]


setup(
    name='boxmot',  # name of pypi package
    version='10.0.43',  # version of pypi package
    python_requires='>=3.8',
    license='AGPL-3.0',
    description=('SOTA tracking methods for detection, segmentation and pose estimation models.'),
    long_description=README,
    long_description_content_type='text/markdown',
    url='https://github.com/mikel-brostrom/yolov8_tracking',
    project_urls={
        'Bug Reports': 'https://github.com/mikel-brostrom/yolo_tracking/issues',
        'Source': 'https://github.com/mikel-brostrom/yolo_tracking'},
    author='Mikel Brostrom',
    author_email='yolov5.deepsort.pytorch@gmail.com',
    packages=find_packages(),  # required
    include_package_data=True,
    install_requires=REQUIREMENTS,
    platforms=["linux"]
)
