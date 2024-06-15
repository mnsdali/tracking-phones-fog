# Python Real-time Location Tracker
<h2> Project Overview</h2>
 
<p align="center">
  <img src="Overview.gif" alt="Project Overview" width="450">
</p>



# Real-time User Location Tracking Server

This Python project is a server application that allows real-time tracking of user locations. Users send their location data from client devices, and the server displays this data on a map. The application uses Flask to create an API that enables clients to send and receive location data.

## Key Features

- **Real-time Tracking**: Track user locations from client devices in real-time.
- **TCP Socket Communication**: Ensure reliable communication between the server and clients.
- **Temporary Location Data Storage**: Store user location data with timestamps for later analysis.
- **Performance Optimization**: Periodically delete old data to ensure optimal performance.
- **Support for Multiple Clients**: Simultaneously manage data from multiple users.

## Getting Started

### Prerequisites

Before starting, make sure you have installed [Python](https://www.python.org/) and the following dependencies in a virtual environment:

### Installation

1. Virtual Environment

    ```sh
    pip install virtualenv
    ```

2. Python Environment

    ```sh
    python -m venv <directory>
    ```

3. Requirements

    - Flask
    - Flask_Cors
    - Requests

4. Clone the repository:

    ```sh
    git clone https://github.com/MohamedBenRhouma/Local-tracking-phones-fog-computing.git
    ```

5. Configure the network settings and ports.

6. Launch the Server application and then the Flutter code:

    ```sh
    python app.py
    ```

## Contributing

All contributions are welcome! If you want to contribute to the development of this project, follow these steps:

1. **Clone the project**:

    ```sh
    git clone https://github.com/MohamedBenRhouma/Local-tracking-phones-fog-computing.git
    ```

2. **Create a new branch** for your work:

    ```sh
    git checkout -b feature/NewFeature
    ```

3. **Make your changes** and ensure you follow the project's coding standards.

4. **Commit your changes** with a descriptive message:

    ```sh
    git commit -m 'Add a new feature'
    ```

5. **Push your branch** to the remote repository:

    ```sh
    git push origin feature/NewFeature
    ```

6. **Open a pull request** on GitHub. Make sure to provide a detailed description of your changes.

7. Your pull request will be reviewed, and once approved, it will be merged into the project.

If you have any questions or ideas to discuss, feel free to open a new issue.

## Acknowledgements

We would like to express our gratitude to the people, projects, and resources that inspired and contributed to this project. Their support has been invaluable and has helped make this project possible.

Special thanks to the following people:

- Mohamed Ali Mnasser: [https://github.com/mnsdali](https://github.com/mnsdali)
- Amine Abid: [https://github.com/Amine-ABID](https://github.com/Amine-ABID)
- Assil Bouaziz

Your support and contributions are greatly appreciated.





  


