import re
import numpy as np
from velodyne import VelodyneDecoder
from utils import *

def main():
    data_path = 'F:\\sensors_calibration_v2\\rawdata\\20221226_calibration\\cameras_lidar_calibration\\VelodyneLidar\\calib_lidarcamera_20221226_1141.pcap'
    camera_timestamps_path = './camera_timestamps1.txt'
    lidar_timestamps_path = './lidar_timestamps1.txt'
    n_skip_packages = 1488000

    config_path = './Alpha Prime.xml'
    output_path = './VelodyneLidar'

    print(data_path)
    print(camera_timestamps_path)
    print(lidar_timestamps_path)
    key = input('Continue?(y/n)[y]')
    if key == 'n' or key == 'N':
        exit()

    # day
    tmp = re.search(r'[0-9]{8}', data_path)
    day = data_path[tmp.regs[0][0]:tmp.regs[0][1]]

    # read camera's timestamps
    with open(camera_timestamps_path, 'r') as f:
        camera_timestamps_str = f.readlines()
    camera_timestamps_str = [t.split('\n')[0] for t in camera_timestamps_str]
    camera_timestamps = np.array(camera_timestamps_str, dtype='float64')

    vd = VelodyneDecoder(config_path=config_path, pcap_path=data_path, output_path=output_path, n_skip_packages=n_skip_packages)

    generate_flags = np.zeros(camera_timestamps.shape, dtype='uint8')
    lidar_timestamps = np.zeros(camera_timestamps.shape, dtype='float64')
    while 1:
        vd.decode_next_packet()
        if vd.judge_jump_cut_degree():
            camera_timestamps_idx_matched, lidar_timestamp = vd.select_generate_frame(camera_timestamps, day, pcd_file_type='pcd')
            if camera_timestamps_idx_matched is not None:
                generate_flags[camera_timestamps_idx_matched] = 1
                lidar_timestamps[camera_timestamps_idx_matched] = lidar_timestamp
                log_GREEN('    camera_timestamp: {}'.format(camera_timestamps_str[camera_timestamps_idx_matched]))
                log_GREEN('    lidar_timestamp: {:.6f}'.format(lidar_timestamps[camera_timestamps_idx_matched]))
                log_GREEN('    time_offset: {:.6f}'.format(
                    camera_timestamps[camera_timestamps_idx_matched] -
                    lidar_timestamps[camera_timestamps_idx_matched]
                ))
            if generate_flags.sum() == len(generate_flags) or (lidar_timestamp - camera_timestamps.max()) > 1:
                log_GREEN('Select done')
                break

    lidar_timestamps_str = ['{:.6f}\n'.format(t) for t in lidar_timestamps]
    with open(lidar_timestamps_path, 'w') as f:
        f.writelines(lidar_timestamps_str)
    log_GREEN('generate {} done'.format(lidar_timestamps_path))

if __name__ == '__main__':
    main()
