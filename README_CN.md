# **hex_nav_orcs_mini**

[English](README.md) | [简体中文](README_CN.md)

---

## **概述**

**hex_nav_orcs_mini** 仓库提供了 **ORCS MINI** 导航套件的演示示例及配置参数。

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

### **维护者**

**[Dong Zhaorui](https://github.com/IBNBlank)**

### **支持的平台**

- [x] **x64**
- [ ] **Jetson Orin Nano**
- [x] **Jetson Orin NX**
- [ ] **Jetson AGX Orin**
- [ ] **Horizon RDK X5**

### **支持的ROS版本**

- [x] **ROS Noetic**
- [ ] **ROS Humble**

---

## **快速开始**

### **依赖项**

- **硬件：** [ORCS MINI Navigation Kit](https://www.hexfellow.com/)
- **Hex Docker：** [`Nav3D` 镜像](https://hub.docker.com/r/hexfellow/hex_docker_noetic_nav3d)
- **Hex Package：**
  - [hex_free_edge](https://github.com/hexfellow/hex_free_edge.git)
  - [hex_livox_preprocess](https://github.com/hexfellow/hex_livox_preprocess.git)
  - [hex_map_3d](https://github.com/hexfellow/hex_map_3d.git)
  - [hex_pcd_localization](https://github.com/hexfellow/hex_pcd_localization.git)
  - [modified FAST_LIO_SAM](https://github.com/hexfellow/FAST_LIO_SAM.git)
  - [modified livox_ros_driver2](https://github.com/hexfellow/livox_ros_driver2.git)

### **安装**

1. 启动 `Nav3D` 容器。更多细节请参见 [`Nav3D` 镜像](https://hub.docker.com/r/hexfellow/hex_docker_noetic_nav3d)。

2. 在容器中编译所有软件包：

    ```shell
    cd ~/catkin_ws
    catkin_make -DCMAKE_BUILD_TYPE=Release
    ```

3. 运行 `setup.bash` 脚本以配置环境：

    ```shell
    source ~/catkin_ws/devel/setup.bash --extend
    ```

---

## **使用方法**

### **地图构建**

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

1. 启动 `Nav3D` 容器。

2. 使用 `tmux` 创建两个窗口，分别用于地图构建和地图保存。

3. 在第一个窗口中运行地图构建启动文件：

    ```shell
    roslaunch hex_nav_orcs_mini demo_real_mapping.launch
    ```

4. 遥控机器人移动来构建地图。

5. 地图构建完成后，在第二个窗口中运行地图保存脚本：

    ```shell
    rosrun hex_map_3d map_save_fast_lio_sam.sh
    ```

6. 通过执行地图预处理脚本生成导航地图：

    ```shell
    rosrun hex_map_3d map_preprocess.sh
    ```

### **导航**

[![wait](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

1. 启动 `Nav3D` 容器。

2. 运行导航启动文件：

    ```shell
    roslaunch hex_nav_orcs_mini demo_real_navigation.launch
    ```

3. 在 RViz 中使用 `2D Pose Estimate` 工具设置初始位姿。

4. 在 `GOAL LIST` 面板中点击 `LOAD GOAL`，加载记录的目标位姿。

5. 在 `MODE` 面板中点击 `SEQUENCE MODE`，切换到顺序模式。

6. 在 `CONTROLLER` 面板中点击 `START/CONTINUE`，开始导航。

### **调试**

1. 启动 `Nav3D` 容器。

2. 使用 `tmux` 创建两个窗口，分别用于驱动程序和数据录制。

3. 在第一个窗口中运行驱动启动文件：

    ```shell
    roslaunch hex_nav_orcs_mini demo_bag_record.launch
    ```

4. 在第二个窗口中启动 rosbag 录制：

    ```shell
    rosrun hex_nav_orcs_mini save_bag.sh
    ```

5. 遥控机器人移动以采集数据。

6. 在录制窗口按下 `Ctrl+C` 保存 bag 文件。默认情况下，文件将保存在 `$(rospack find hex_nav_orcs_mini)/bags`。

7. 使用保存的 bag 文件通过 `demo_bag_mapping.launch` 和 `demo_bag_navigation.launch` 测试地图构建与导航。

---

## **硬件驱动**

硬件驱动通过位于 `hex_nav_orcs_mini/launch/include/hardware/drivers` 的 `.launch` 文件启动。

### **Vehicle**

- **Launch 代码:**

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

- **关键接口：**

  - **Publish:**
    - `/cmd_vel` (geometry_msgs/Twist)

  - **Subscribe:**
    - `/odom` (nav_msgs/Odometry)

### **MID360**

- **Launch 代码:**

    ```xml
    <launch>
        ...
        <!-- MID360 -->
        <include file="$(find livox_ros_driver2)/launch_ROS1/msg_MID360.launch" />
        ...
    </launch>
    ```

- **关键接口：**

  - **Publish:**
    - `/livox/lidar` (sensor_msgs/PointCloud2)
    - `/livox/imu` (sensor_msgs/Imu)

### **IMU**

- **Launch 代码:**

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

- **关键接口：**

  - **Publish:**
    - `/imu_data` (sensor_msgs/Imu)
    - `/magnetic_data` (geometry_msgs/Vector3)

---

## **延伸阅读**

1. 查阅相关 **Hex Package** 以获取更多细节。
2. 尝试修改 `hex_nav_orcs_mini/launch` 目录下 `.launch` 和 `.yaml` 文件中的参数，观察不同配置下的效果。
