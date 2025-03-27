# **hex_nav_orcs_mini**

## **Overview**

The **hex_nav_orcs_mini** repository provides demos and configuration parameters for the **ORCS MINI** navigation kit.

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

[Bilibili Url](https://www.bilibili.com/video/BV1GJ411x7h7)

### **License**

This project is licensed under the terms of the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

### **Maintainer**

**[Dong Zhaorui](https://github.com/IBNBlank)**

### **Supported Platform**

- [x] **x64**
- [ ] **Jetson Orin Nano**
- [x] **Jetson Orin NX**
- [ ] **Jetson AGX Orin**
- [ ] **Horizon RDK X5**

### **Supported ROS Version**

- [x] **ROS Noetic**
- [ ] **ROS Humble**

---

## **Getting Started**

### **Dependencies**

- **Hardware:** [ORCS MINI Navigation Kit](https://www.hexfellow.com/)
- **Hex Docker:** [`Nav3D` image](https://hub.docker.com/r/hexfellow/hex-docker-noetic-nav3d)
- **Hex Package:**
  - [hex_free_edge](https://github.com/hexfellow/hex_free_edge.git)
  - [hex_livox_preprocess](https://github.com/hexfellow/hex_livox_preprocess.git)
  - [hex_map_3d](https://github.com/hexfellow/hex_map_3d.git)
  - [hex_pcd_localization](https://github.com/hexfellow/hex_pcd_localization.git)
  - [modified FAST_LIO_SAM](https://github.com/hexfellow/FAST_LIO_SAM.git)
  - [modified livox_ros_driver2](https://github.com/hexfellow/livox_ros_driver2.git)

### **Installation**

1. Start the `Nav3D` container. Refer to [`Nav3D` image](https://hub.docker.com/r/hexfellow/hex-docker-noetic-nav3d) for more details.

2. Compile the packages in the container:

    ```shell
    cd ~/catkin_ws
    catkin_make -DCMAKE_BUILD_TYPE=Release
    ```

3. Source `setup.bash` script to configure your environment:

    ```shell
    source ~/catkin_ws/devel/setup.bash --extend
    ```

---

## **Usage**

### **Mapping**

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

[Bilibili Url](https://www.bilibili.com/video/BV1GJ411x7h7)

1. Start the `Nav3D` container.

2. Use `tmux` to create two windows for mapping and map saving.

3. Run the mapping launch file in the first window.

    ```shell
    roslaunch hex_nav_orcs_mini demo_real_mapping.launch
    ```

4. Teleop the robot move around to map.

5. Once mapping is complete, run the map saving script in the second window:

    ```shell
    rosrun hex_map_3d map_save_fast_lio_sam.sh
    ```

6. Generate the navigation map by executing the map preprocessing script:

    ```shell
    rosrun hex_map_3d map_preprocess.sh
    ```

### **Navigation**

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

[Bilibili Url](https://www.bilibili.com/video/BV1GJ411x7h7)

1. Start the `Nav3D` container.

2. Run the navigation launch file:

    ```shell
    roslaunch hex_nav_orcs_mini demo_real_navigation.launch
    ```

3. Set the initial pose in RViz using the `2D Pose Estimate` tool.

4. Click `LOAD GOAL` in the `GOAL LIST` panel to load the recorded goal poses.

5. Click `SEQUENCE MODE` in the `MODE` panel to switch to sequence mode.

6. Click `START/CONTINUE` in the `CONTROLLER` panel to start navigation.

### **Debugging**

1. Start the `Nav3D` container.

2. Use `tmux` to create two windows for drivers and recording.

3. Run the drivers in the first window:

    ```shell
    roslaunch hex_nav_orcs_mini demo_bag_record.launch
    ```

4. Start the rosbag recorder in the second window:

    ```shell
    rosrun hex_nav_orcs_mini save_bag.sh
    ```

5. Teleoperate the robot to capture data.

6. Press `Ctrl+C` in the recorder window. The bag is saved by default in `$(rospack find hex_nav_orcs_mini)/bags`.

7. Use the saved bag file with `demo_bag_mapping.launch` and `demo_bag_navigation.launch` to test mapping and navigation.

---

## **Hardware Drivers**

Hardware drivers are started via the `.launch` file located at `hex_nav_orcs_mini/launch/include/hardware/drivers`.

### **Vehicle**

- **Launch Code:**

    ```xml
    <launch>
        <!-- Vehicle -->
        <node name="xnode_vehicle" pkg="xpkg_vehicle" type="xnode_vehicle" respawn="false" output="screen" required="false">
            <param name="can_device" value="can0"/>
            <param name="calc_odom_from_speed" value="false"/>
            <remap from="/cmd_vel" to="/cmd_vel" />
            <remap from="/odom" to="/odom" />
        </node>
        ...
    </launch>
    ```

- **Key Interfaces:**

  - **Publish:**
    - `/cmd_vel` (geometry_msgs/Twist)

  - **Subscribe:**
    - `/odom` (nav_msgs/Odometry)

### **MID360**

- **Launch Code:**

    ```xml
    <launch>
        ...
        <!-- MID360 -->
        <include file="$(find livox_ros_driver2)/launch_ROS1/msg_MID360.launch" />
        ...
    </launch>
    ```

- **Key Interfaces:**

  - **Publish:**
    - `/livox/lidar` (sensor_msgs/PointCloud2)
    - `/livox/imu` (sensor_msgs/Imu)

### **IMU**

- **Launch Code:**

    ```xml
    <launch>
        ...
        <!-- IMU -->
        <node name="xnode_imu" pkg="xpkg_imu" type="xnode_imu" respawn="false" output="screen" required="false">
            <param name="can_device" value="can0"/>
            <param name="frame_name" value="imu_frame"/>
            <param name="specify_id_type" value="0"/>
            <param name="specify_id_number" value="0"/>
            <remap from="/imu_data" to="/imu_data" />
            <remap from="/magnetic_data" to="/magnetic_data" />
        </node>
    </launch>
    ```

- **Key Interfaces:**

  - **Publish:**
    - `/imu_data` (sensor_msgs/Imu)
    - `/magnetic_data` (geometry_msgs/Vector3)

---

## **Notes**

1. The default `ip` address of the IPC of the kit is `192.168.1.50`.
2. The default `WiFi` name of the kit is `HexRouter_xxxx`.
