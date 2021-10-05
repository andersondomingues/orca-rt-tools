# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

# dump the file content to a string
with open('README.md') as f:
    readme = f.read()

with open('LICENSE') as f:
    license = f.read()

# creates a list where the lines are stored in consecutive positions
required = [line.strip() for line in open("requirements.txt").readlines()]

setup(
    name='rt_tools',
    version='0.1',
    description='real-time analysis for network-on-chips',
    long_description=readme,
    author='Anderson Domingues',
    author_email='ti.andersondomingues@gmail.com',
    url='https://github.com/andersondomingues/rt-analysis-hermes/',
    license=license,
    # specify the dir of the python modules to be installed
    packages=find_packages('rt_tools'),
    # specify the data files that must be installed
    include_package_data=True,
    package_data={
        # If any package contains *.txt files, include them:
        #"": ["*.txt"],
        # And include any *.dat files found in the "data" subdirectory
        # of the "mypkg" package, also:
        "": ["models/*.amxmi"],
    },
    # exclude READMEs from instalation
    exclude_package_data={"": ["README.md", 'readme.md']},  
    # depedencies  
    install_requires=required,
    # execution entry point. to launch the python application as an executable.
    entry_points='''
        [console_scripts]
        rt_tools=rt_tools.__main__:main
    '''
)
