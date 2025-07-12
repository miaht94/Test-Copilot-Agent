FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy dbt profiles
COPY profiles.yml /root/.dbt/profiles.yml

# Create .dbt directory if it doesn't exist
RUN mkdir -p /root/.dbt

CMD ["tail", "-f", "/dev/null"]