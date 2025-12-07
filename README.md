# Infrastructure for Spring Boot Demo

Welcome! This project contains the necessary infrastructure to run a local Docker registry, which will be used in our CI/CD pipeline for the Spring Boot demo application.

## 1. Introduction: What's the Goal?

In a previous session, we created a sample Spring Boot project. You can find a specific version of it at this URL: `https://github.com/Curs-DevOps/spring-demo/tree/d15110d22fb3523e6bc061628c8be9cbdb58583e`.

Our goal is to take that application and build a complete CI/CD (Continuous Integration/Continuous Deployment) pipeline. This pipeline will automatically:
1.  Build our application into a Docker image.
2.  Push that image to a private Docker registry.
3.  (In a real-world scenario) Deploy the new image to a server.

This `infra` project provides the private Docker registry.

## 2. Understanding the Infrastructure (`docker-compose.yml`)

This project uses Docker Compose to run a multi-container Docker application. Our setup has two services: a Docker Registry and a User Interface for it.

### Why do we need this?

When you build a Docker image, it only exists on your local machine. To share it or use it in an automated workflow (like deploying it to a server), you need a central storage place. That's what a **Docker Registry** is. Docker Hub is a public registry, but companies often use private registries for their own applications.

Here, we are running our own private registry locally.

-   **`registry` service**: This is the actual Docker registry. It's a service that stores and distributes Docker images. We've configured it to run on port `6081` on your local machine.

-   **`registry-ui` service**: A registry is just an API; it doesn't have a user interface. This service provides a simple, web-based UI so we can browse the images stored in our registry. You can access it at `http://localhost:6080`.

## 3. GitHub Actions and Self-Hosted Runners

### What are GitHub Actions?

GitHub Actions is a CI/CD platform integrated into GitHub. It allows you to automate your build, test, and deployment pipeline. You define a "workflow" in a YAML file in your repository (`.github/workflows/`). GitHub then runs this workflow automatically when certain events happen, like a `push` to your `main` branch.

### Why a Self-Hosted Runner?

GitHub provides its own virtual machines (runners) to execute your workflows. However, sometimes you need your workflow to run in a specific environment. In our case, the workflow needs to push a Docker image to our **local** registry running at `localhost:6081`.

A GitHub-hosted runner is on a server somewhere in the cloud and has no access to your `localhost`.

A **self-hosted runner** is a machine that *you* control (it could be your own laptop or a server you manage) that you connect to GitHub Actions. By running the runner on the same machine where our Docker registry is running, the runner can access `localhost:6081` and push the image.

## 4. Step-by-Step Guide to Build the Pipeline

Follow these steps carefully to get your own automated pipeline running.

### Step 1: Get the Application Code

First, you need to clone the specific version of the `spring-demo` application.

```bash
# Clone the repository
git clone https://github.com/Curs-DevOps/spring-demo.git

# Navigate into the directory
cd spring-demo

# Check out the specific commit
git checkout d15110d22fb3523e6bc061628c8be9cbdb58583e
```

You now have the correct version of the code. Leave this terminal window open.

### Step 2: Create Your Own GitHub Repository

1.  Go to GitHub and create a **new, empty repository**. Do not initialize it with a README or .gitignore.
2.  Clone your new, empty repository into a **different directory**.

    ```bash
    # In a new terminal, outside the spring-demo directory
    git clone <your-new-repo-url>
    cd <your-new-repo-name>
    ```

### Step 3: Copy, Commit, and Push the Code

1.  Copy all the files and folders (including hidden ones like `.git`) from the `spring-demo` directory into your new repository's directory.
2.  In the terminal for your **new repository**, add the files, commit them, and push them to GitHub.

    ```bash
    # Make sure you are in your new repository's directory
    git add .
    git commit -m "Initial commit of the Spring Boot application"
    git push origin main
    ```

### Step 4: Run the Local Infrastructure

Now, let's start the Docker registry. In the directory of **this `infra` project**:

```bash
# This will start the registry and the UI in the background
docker-compose up -d
```

### Step 5: Check the Registry UI

Open your web browser and navigate to `http://localhost:6080`. You should see the UI for your local registry. It will be empty for now.

### Step 6: Add the GitHub Actions Workflow

In your **new application repository** (the one with the Spring Boot code), create the following directory and file structure:

`.github/workflows/build-and-deploy.yml`

Copy the content from the `build-and-deploy.yml` file provided in the course material into this new file. This file tells GitHub Actions what to do.

### Step 7: Set Up and Run the Self-Hosted Runner

1.  In your browser, go to your new GitHub repository.
2.  Navigate to **Settings > Actions > Runners**.
3.  Click on **New self-hosted runner**.
4.  Choose the operating system (e.g., Linux, macOS, Windows).
5.  GitHub will provide you with a set of commands. Open a new terminal and run them one by one. They will look something like this:

    ```bash
    # Download the runner package
    mkdir actions-runner && cd actions-runner
    curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
    tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

    # Configure the runner (it will ask for your repo URL and a token)
    ./config.sh --url <your-repo-url> --token <your-token>

    # Run the runner
    ./run.sh
    ```

**Important**: Keep this terminal window open! The runner must be active and listening for jobs. You should see the output `Listening for Jobs`.

### Step 8: Push the Workflow and See the Magic!

Now, commit and push the workflow file you created in Step 6.

```bash
# In your application repository's directory
git add .github/workflows/build-and-deploy.yml
git commit -m "feat: Add CI/CD workflow"
git push
```

As soon as you push, two things will happen:
1.  The terminal running your self-hosted runner will spring to life and start executing the job.
2.  You can go to the "Actions" tab in your GitHub repository to watch the workflow run in real-time.

Once the workflow is complete, refresh the registry UI at `http://localhost:6080`. You should now see your `myapp/demo` image listed!

Congratulations, you have successfully set up a complete, local CI/CD pipeline!