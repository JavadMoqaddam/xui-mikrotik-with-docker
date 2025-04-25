# Connect Mikrotik and 3x-ui on Docker


#### Usage

1. **Install Docker:**

   ```sh
   bash <(curl -sSL https://get.docker.com)
   ```


2. **Clone the Project Repository:**

   ```sh
   git clone https://github.com/idaniali/xui-mikrotik-with-docker.git
   cd xui-mikrotik-with-docker
   ```


3. **Create a suitable network for the project**

   ```shell
   docker network create \
    --driver=bridge \
    --subnet=192.168.25.0/24 \
    --ip-range=192.168.25.0/24 \
    --gateway=192.168.25.254 \
    sninet
   ```




4. **Start the Service:**

   ```sh
   docker compose up -d
   ```

