
NAMESPACE=default
REGISTRY=mycluster.icp:8500
VERSION=1.1

# Install Container Structure test if not already in the system
# curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 && chmod +x container-structure-test-linux-amd64 && sudo mv container-structure-test-linux-amd64 /usr/local/bin/container-structure-test


# Build the new container based on the source code provided and the specifications in Dockerfile
docker build -t mycluster.icp:8500/default/hello-container:${VERSION} .

# Check that the new container is available in docker engine
docker images | grep hello-container

# Logon to the ICP Private Docker Repository
docker login --username=admin --password=admin mycluster.icp:8500

# Check the container just created for consistency with Docker Best Practices
container-structure-test  -test.v   -image \${REGISTRY}/\${NAMESPACE}/hello-container:${VERSION} /opt/git/hellocontainer/hello-container-test.yaml

# Delete old versions of the app from the ICP Private Docker Repository
kubectl delete images hello-container:latest

# Push the new version of the app to the ICP Private Docker Repository
docker push  mycluster.icp:8500/default/hello-container:${VERSION}

# Tag the version just pushed as the 'latest'
docker tag   mycluster.icp:8500/default/hello-container:${VERSION} mycluster.icp:8500/default/hello-container:latest

# Confirm the image in Docker was pushed to Kubernetes
kubectl get images

# Create the Service point
kubectl create -f /opt/git/hellocontainer.deployment.yml

# Delete old versions of the deployment of this app if any running.
helm delete hellocontainer --purge --tls

# Install the new version of the app
helm install ./hellocontainer-chart/ -n hellocontainer --tls
# helm upgrade hello-container ./hellocontainer-chart/ --set image.repository=\${REGISTRY}/\${NAMESPACE}/hello-container --set image.tag=${VERSION} -n hellocontainer --tls

# Verify the new version was deployed
helm list --tls | grep hello

# Verify the associated services are available and check the port in which the new application is running
kubectl get services | grep hello

