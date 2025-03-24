#!/usr/bin/env bash
################################################################
# Copyright 2025 Dong Zhaorui. All rights reserved.
# Author: Dong Zhaorui 847235539@qq.com
# Date  : 2025-03-21
################################################################

bag_name=$1
if [ -z "$bag_name" ]; then
    bag_name="mark2_test_$(date -d today +%Y%m%d_%H%M%S)"
fi

if [ ! -d "$(rospack find hex_nav_orcs_mini)/bags" ]; then
    mkdir $(rospack find hex_nav_orcs_mini)/bags
fi

rosbag record -O $(rospack find hex_nav_orcs_mini)/bags/$bag_name /livox/imu /livox/lidar /odom 