# Multi-Sensors Calibration

## EXP1：zhoushan_20221217_20221221

![image-20230302144639381](assets/image-20230302144639381.png)

### camera_intrinsic

Camera Calibration Toolbox for Matlab

#### IRayCamera_intrinsic

<img src="assets/image-20230228191435259.png" alt="image-20230228191435259" style="zoom:33%;" />

#### LeopardCamera0_intrinsic

<img src="assets/image-20230228191340229.png" alt="image-20230228191340229" style="zoom:33%;" />

#### LeopardCamera1_intrinsic

<img src="assets/image-20230228191500145.png" alt="image-20230228191500145" style="zoom:33%;" />

### camera_extrinsic

Stereo Camera Cailbrator for Matlab

#### LeopardCamera1_to_LeopardCamera0_extrinsic

<img src="assets/image-20230228191905993.png" alt="image-20230228191905993" style="zoom:33%;" />

### OCULiiRadar_to_camera_extrinsic

use L-M optimization algorithm

at present, the vertical direction error is large, other methods will follow

#### OCULiiRadar_to_IRayCamera_extrinsic

<img src="assets/error.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1.png" alt="match_20221217_1" style="zoom:50%;" />

#### OCULiiRadar_to_LeopardCamera0_extrinsic

<img src="assets/error-1677583805188-3.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1-1677583811688-5.png" alt="match_20221217_1" style="zoom:50%;" />

#### OCULiiRadar_to_LeopardCamera1_extrinsic

<img src="assets/error-1677583831851-7.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1-1677583836626-9.png" alt="match_20221217_1" style="zoom:50%;" />

### TIRadar_calibration

use TI mmwave cascade example codes

<img src="assets/image-20230228192511662.png" alt="image-20230228192511662" style="zoom: 50%;" /><img src="assets/image-20230228192531301.png" alt="image-20230228192531301" style="zoom:50%;" />

### TIRadar_to_camera_extrinsic

use L-M optimization algorithm

#### TIRadar_to_IRayCamera_extrinsic

<img src="assets/error-1677583963407-11.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1-1677583969326-13.png" alt="match_20221217_1" style="zoom:50%;" />

#### TIRadarRadar_to_LeopardCamera0_extrinsic

<img src="assets/error-1677583979804-15.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1-1677583985647-17.png" alt="match_20221217_1" style="zoom:50%;" />

#### TIRadarRadar_to_LeopardCamera1_extrinsic

<img src="assets/error-1677583995566-19.png" alt="error" style="zoom:50%;" /><img src="assets/match_20221217_1-1677583999958-21.png" alt="match_20221217_1" style="zoom:50%;" />

### VelodyneLidar_to_camera_extrinsic

#### VelodyneLidar_to_LeopardCamera0_extrinsic

<img src="assets/image16775841015380.png" alt="img" style="zoom: 50%;" /><img src="assets/image16775841198490.png" alt="img" style="zoom: 50%;" />

#### VelodyneLidar_to_LeopardCamera1_extrinsic

<img src="assets/image16775841507150.png" alt="img" style="zoom:50%;" /><img src="assets/image16775841707160.png" alt="img" style="zoom:50%;" />

### MEMS_to_Vehicle_extrinsic

使用[SensorsCalibration/imu_heading at master · PJLab-ADG/SensorsCalibration (github.com)](https://github.com/PJLab-ADG/SensorsCalibration/tree/master/imu_heading)进行标定

### MEMS_to_VelodyneLiadr_extrinsic

使用[SensorsCalibration/lidar2imu at master · PJLab-ADG/SensorsCalibration (github.com)](https://github.com/PJLab-ADG/SensorsCalibration/tree/master/lidar2imu)进行标定

## EXP2：yantai_20221223_20221226

![image-20230302144718651](assets/image-20230302144718651.png)

### camera_intrinsic

#### IRayCamera_intrinsic

#### LeopardCamera0_intrinsic

#### LeopardCamera1_intrinsic

### camera_extrinsic

#### LeopardCamera1_to_LeopardCamera0_extrinsic

### OCULiiRadar_to_camera_extrinsic

#### OCULiiRadar_to_IRayCamera_extrinsic

#### OCULiiRadar_to_LeopardCamera0_extrinsic

#### OCULiiRadar_to_LeopardCamera1_extrinsic

### TIRadar_calibration

### TIRadar_to_camera_extrinsic

#### TIRadar_to_IRayCamera_extrinsic

#### TIRadar_to_LeopardCamera0_extrinsic

#### TIRadar_to_LeopardCamera1_extrinsic

### VelodyneLidar_to_camera_extrinsic

#### VelodyneLidar_to_IRayCamera_extrinsic

#### VelodyneLidar_to_LeopardCamera0_extrinsic

#### VelodyneLidar_to_LeopardCamera1_extrinsic

### MEMS_to_Vehicle_extrinsic

### MEMS_to_VelodyneLiadr_extrinsic



