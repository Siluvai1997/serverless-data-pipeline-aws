#!/bin/bash
pip install -r requirements.txt -t .
zip -r lambda.zip . -x "__pycache__/*"