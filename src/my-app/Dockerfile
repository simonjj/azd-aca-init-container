# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file and install them
COPY app.py .
RUN pip install Flask

# Command to run the app
CMD ["python", "app.py"]
