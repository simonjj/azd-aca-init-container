# Use a lightweight base image
FROM alpine:latest

# The command to run. It sleeps for 5s, writes a file to the shared volume,
# and then exits. The container must exit for the main container to start.
CMD ["/bin/sh", "-c", "echo 'Init container running...' && sleep 5 && echo 'Init complete. Writing to shared volume.' && echo 'Hello from the init container!' > /shared/data.txt"]
