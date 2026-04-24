# Installation and Reproducibility (One-Click Deployment via Docker)

This project utilizes **Docker Compose** to fully automate the database deployment process.

## Step 1: Initialize the Docker Engine
First, make sure Docker is actively running in the background, as shown below:
<img width="233" height="45" alt="image" src="https://github.com/user-attachments/assets/af13dfef-c366-4f11-a53c-c257f7a1fb30" />

## Step 2: Open a Terminal in the Target Directory
Ensure that the `docker-compose.yml` and `TABLE_CREATION_SCRIPTS.sql` files are located within the same directory. Navigate to this directory using your terminal.

## Step 3: Execute the Initialization Command
Proceed to the terminal and execute the following command:

`docker-compose up -d`

When you see the word "Started" or "Running" in green on the screen, as shown in the image below, it means a virtual server has been set up.

*Note: When the container is started for the first time, the `TABLE_CREATION_SCRIPTS.sql` file is automatically triggered and all tables/indexes are created in the system immediately.*


## Step 4: Database Connection (via DBeaver or any SQL Client)**
Once the database is operational, you may establish a connection using the following credentials:
* **Host:** `localhost`
* **Port:** `1521`
* **SID / Service Name:** `XEPDB1`
* **Username:** `telco_admin` (or `system`)
* **Password:** `telco123` (or `oracle`)

*Note: on Credentials:*

Use the **`telco_admin`** account for standard operations, such as accessing and managing project-specific tables and data.

Use the **`system`** account only if you need advanced database administration or system-level configuration.


## Step 5: Terminating the Environment**
Upon completion of your testing, execute the following command to cleanly shut down the environment:

`docker-compose down`
