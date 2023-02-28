import re
import numpy as np
from oculii_np import OCULiiDecoderNetworkPackets, PtpTriggerPacket
from utils import *

def decode_network_packets():
    data_path = 'F:\\sensors_calibration_v2\\rawdata\\20221217_calibration\\cameras_radars_calibration\\OCULiiRadar\\20221217OCU标定2.pcap'
    output_path = './OCULiiRadar'
    camera_timestamps_path = './camera_timestamps1.txt'
    OCULiiRadar_timestamps_path = './OCULiiRadar_timestamps1.txt'

    # day
    tmp = re.search(r'[0-9]{8}', data_path)
    day = data_path[tmp.regs[0][0]:tmp.regs[0][1]]

    # read camera's timestamps
    with open(camera_timestamps_path, 'r') as f:
        camera_timestamps_str = f.readlines()
    camera_timestamps_str = [t.split('\n')[0] for t in camera_timestamps_str]
    camera_timestamps = np.array(camera_timestamps_str, dtype='float64')

    odnp = OCULiiDecoderNetworkPackets(pcap_path=data_path, output_path=output_path, pcd_file_type='pcd')

    odnp.generate_flags = np.zeros(camera_timestamps.shape, dtype='uint8')
    odnp.OCULiiRadar_timestamps = np.zeros(camera_timestamps.shape, dtype='float64')
    odnp.OCULiiRadar_timestamps_path = OCULiiRadar_timestamps_path

    # find ptp trigger packet
    while not odnp.after_ptp_trigger:
        idx_packet, ts, pkg = odnp.next_udp_packet()
        if PtpTriggerPacket.is_PtpTriggerPacket(pkg):
            log_BLUE('[{:.6f}] idx_packet={}, ptp_trigger_packet transfer'.format(ts, idx_packet))
            idx_packet, ts, pkg = odnp.next_udp_packet()
            if PtpTriggerPacket.is_PtpTriggerPacket(pkg):
                log_BLUE('[{:.6f}] idx_packet={}, ptp_trigger_packet confirm'.format(ts, idx_packet))
                odnp.after_ptp_trigger = True
                continue
        print('[{:.6f}] idx_packet={}, before ptp_trigger_packet, skip'.format(ts, idx_packet))

    # decode after ptp trigger packet
    while odnp.after_ptp_trigger:
        odnp.next_frame_packets()
        if odnp.packets_in_frame[0].is_ptp_sync:
            # generate pointcloud frame
            camera_timestamps_idx_matched, OCULiiRadar_timestamp = odnp.select_generate_frame(camera_timestamps, day)

            if camera_timestamps_idx_matched is not None:
                odnp.generate_flags[camera_timestamps_idx_matched] = 1
                odnp.OCULiiRadar_timestamps[camera_timestamps_idx_matched] = OCULiiRadar_timestamp
                log_GREEN('    camera_timestamp: {}'.format(camera_timestamps_str[camera_timestamps_idx_matched]))
                log_GREEN('    OCULiiRadar_timestamp: {:.6f}'.format(odnp.OCULiiRadar_timestamps[camera_timestamps_idx_matched]))
                log_GREEN('    time_offset: {:.6f}'.format(
                    camera_timestamps[camera_timestamps_idx_matched] -
                    odnp.OCULiiRadar_timestamps[camera_timestamps_idx_matched]
                ))

            if odnp.generate_flags.sum() == len(odnp.generate_flags):
                log_GREEN('Select done')
                break
        else:
            # skip
            log_YELLOW('    not ptp sync')

        # new frame init
        odnp.init_for_next_frame()

    OCULiiRadar_timestamps_str = ['{:.6f}\n'.format(t) for t in odnp.OCULiiRadar_timestamps]
    with open(OCULiiRadar_timestamps_path, 'w') as f:
        f.writelines(OCULiiRadar_timestamps_str)
    log_GREEN('generate {} done'.format(OCULiiRadar_timestamps_path))

if __name__ == '__main__':
    decode_network_packets()

