'''
Author: FranzKafka
Date: 2024-11-11 09:21:03
LastEditTime: 2024-11-11 09:24:57
LastEditors: Franzkafka
Description: 
FilePath: \AppInspector\result.py
可以输入预定的版权声明、个性签名、空行等
'''
import re
from datetime import datetime
from typing import Dict, List, Any
import matplotlib.pyplot as plt
from collections import defaultdict

class PerformanceParser:
    def __init__(self):
        self.result: Dict[str, Any] = {
            'timestamps': [],
            'app_info': {
                'package_name': '',
                'location': '',
                'size': '',
            },
            'permissions': {
                'requested': [],
                'install': {},
                'runtime': {}
            },
            'performance_data': defaultdict(list)  # 存储时间序列数据
        }
        self.current_timestamp = None

    def parse_file(self, file_path: str) -> Dict[str, Any]:
        """解析性能数据文件"""
        current_section = ''
        section_content = []
        in_permission_section = False
        last_timestamp = None  # 用于跟踪上一个时间戳
        
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.readlines()
                
                for line in content:
                    line = line.strip()
                    
                    # 检测时间戳
                    if 'Time:' in line:
                        current_timestamp = line.split('Time:')[1].strip()
                        # 只有当时间戳变化时才更新
                        if current_timestamp != last_timestamp:
                            self.current_timestamp = current_timestamp
                            last_timestamp = current_timestamp
                            if self.current_timestamp not in self.result['timestamps']:
                                self.result['timestamps'].append(self.current_timestamp)
                        continue

                    # 检测权限部分
                    if 'requested permissions:' in line:
                        in_permission_section = True
                        current_section = 'requested'
                        continue
                    elif 'install permissions:' in line:
                        in_permission_section = True
                        current_section = 'install'
                        continue
                    elif 'runtime permissions:' in line:
                        in_permission_section = True
                        current_section = 'runtime'
                        continue
                    
                    # 解析权限
                    if in_permission_section and line:
                        if current_section == 'requested' and (line.startswith('android.') or 
                                                            line.startswith('com.') or 
                                                            line.startswith('ohos.')):
                            if line not in self.result['permissions']['requested']:
                                self.result['permissions']['requested'].append(line)
                        elif current_section in ['install', 'runtime'] and ':' in line:
                            if 'granted=' in line:
                                permission, status = line.split(':', 1)
                                permission = permission.strip()
                                granted = 'granted=true' in status.lower()
                                self.result['permissions'][current_section][permission] = granted

                    # 解析应用信息
                    if 'name' in line and 'location:' in line.lower():
                        parts = line.split('location:')
                        self.result['app_info']['package_name'] = parts[0].split('name')[1].strip()
                        self.result['app_info']['location'] = parts[1].strip()
                    elif 'name' in line and 'size:' in line:
                        self.result['app_info']['size'] = line.split('size:')[1].strip()

                    # 解析性能数据
                    if self.current_timestamp:
                        if 'e.unity3d' in line and 'grep' not in line:
                            try:
                                parts = line.split()
                                if len(parts) >= 9:
                                    cpu_usage = float(parts[8].strip('[]%'))
                                    # 检查是否已经有该时间戳的数据
                                    existing_data = next(
                                        (item for item in self.result['performance_data']['cpu'] 
                                         if item['timestamp'] == self.current_timestamp), 
                                        None
                                    )
                                    if existing_data:
                                        # 更新现有数据，取最大值
                                        existing_data['value'] = max(existing_data['value'], cpu_usage)
                                    else:
                                        # 添加新数据
                                        self.result['performance_data']['cpu'].append({
                                            'timestamp': self.current_timestamp,
                                            'value': cpu_usage
                                        })
                            except (ValueError, IndexError) as e:
                                print(f"Error parsing CPU usage: {e}")
                        
                        # 解析内存信息
                        if 'TOTAL PSS:' in line:
                            try:
                                pss_match = re.search(r'TOTAL PSS:\s*(\d+)', line)
                                if pss_match:
                                    pss_value = int(pss_match.group(1))
                                    existing_data = next(
                                        (item for item in self.result['performance_data']['memory'] 
                                         if item['timestamp'] == self.current_timestamp), 
                                        None
                                    )
                                    if existing_data:
                                        # 更新现有数据，取最大值
                                        existing_data['value'] = max(existing_data['value'], pss_value)
                                    else:
                                        # 添加新数据
                                        self.result['performance_data']['memory'].append({
                                            'timestamp': self.current_timestamp,
                                            'value': pss_value
                                        })
                            except (ValueError, IndexError) as e:
                                print(f"Error parsing memory: {e}")
            
            return self.result
            
        except Exception as e:
            print(f"Error parsing file: {e}")
            return self.result

def plot_performance_data(result):
    """绘制性能数据图表"""
    plt.style.use('bmh')
    
    # 创建图表
    fig = plt.figure(figsize=(15, 10))
    
    # 准备数据
    cpu_data = result['performance_data']['cpu']
    memory_data = result['performance_data']['memory']
    
    # 确保数据和时间戳一一对应
    cpu_timestamps = [x['timestamp'] for x in cpu_data]
    cpu_values = [x['value'] for x in cpu_data]
    memory_timestamps = [x['timestamp'] for x in memory_data]
    memory_values = [x['value']/1024 for x in memory_data]  # 转换为MB
    
    # 优化时间戳显示
    def format_timestamp(timestamp):
        try:
            dt = datetime.strptime(timestamp, "%a %b %d %H:%M:%S %Z-%Y")
            return dt.strftime("%H:%M:%S")  # 只显示时:分:秒
        except:
            return timestamp
    
    formatted_cpu_timestamps = [format_timestamp(ts) for ts in cpu_timestamps]
    formatted_memory_timestamps = [format_timestamp(ts) for ts in memory_timestamps]
    
    # CPU使用率子图
    ax1 = plt.subplot(211)
    ax1.plot(range(len(cpu_values)), cpu_values, 'b-o', linewidth=2, markersize=6)
    ax1.set_title('CPU Usage Over Time', fontsize=14, pad=15)
    ax1.set_xlabel('Time', fontsize=12)
    ax1.set_ylabel('CPU Usage (%)', fontsize=12)
    ax1.grid(True, linestyle='--', alpha=0.7)
    
    # 设置CPU图的x轴标签
    num_ticks = min(10, len(cpu_timestamps))  # 最多显示10个标签
    tick_indices = list(range(0, len(cpu_timestamps), max(1, len(cpu_timestamps) // num_ticks)))
    if tick_indices[-1] != len(cpu_timestamps) - 1:
        tick_indices.append(len(cpu_timestamps) - 1)
    
    ax1.set_xticks(tick_indices)
    ax1.set_xticklabels([formatted_cpu_timestamps[i] for i in tick_indices], rotation=45, ha='right')
    
    # 内存使用子图
    ax2 = plt.subplot(212)
    ax2.plot(range(len(memory_values)), memory_values, 'g-s', linewidth=2, markersize=6)
    ax2.set_title('Memory Usage Over Time', fontsize=14, pad=15)
    ax2.set_xlabel('Time', fontsize=12)
    ax2.set_ylabel('Memory Usage (MB)', fontsize=12)
    ax2.grid(True, linestyle='--', alpha=0.7)
    
    # 设置内存图的x轴标签
    memory_tick_indices = list(range(0, len(memory_timestamps), max(1, len(memory_timestamps) // num_ticks)))
    if memory_tick_indices[-1] != len(memory_timestamps) - 1:
        memory_tick_indices.append(len(memory_timestamps) - 1)
    
    ax2.set_xticks(memory_tick_indices)
    ax2.set_xticklabels([formatted_memory_timestamps[i] for i in memory_tick_indices], rotation=45, ha='right')
    
    # 添加数据标签（每隔几个点添加一个标签，避免过密）
    label_interval = max(len(cpu_values) // 10, 1)  # 根据数据点数量调整标签间隔
    
    # 只为非零值添加标签
    for i in range(0, len(cpu_values), label_interval):
        if cpu_values[i] > 0.1:  # 只为大于0.1%的值添加标签
            ax1.annotate(f'{cpu_values[i]:.1f}%', 
                        (i, cpu_values[i]), 
                        textcoords="offset points", 
                        xytext=(0,10), 
                        ha='center',
                        fontsize=8)
    
    # 为内存图添加首尾和关键点的标签
    important_points = [0, -1]  # 首尾点
    for i in important_points:
        ax2.annotate(f'{memory_values[i]:.1f}MB', 
                    (i, memory_values[i]), 
                    textcoords="offset points", 
                    xytext=(0,10), 
                    ha='center',
                    fontsize=8)
    
    # 调整布局
    plt.tight_layout()
    
    # 保存图表
    plt.savefig('performance_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()

def main():
    parser = PerformanceParser()
    result = parser.parse_file('result.txt')
    
    # 打印应用基本信息
    print("\nApplication Information:")
    print(f"Package Name: {result['app_info']['package_name']}")
    print(f"Location: {result['app_info']['location']}")
    print(f"Size: {result['app_info']['size']}")
    
    # 打印权限信息
    print("\nPermissions Summary:")
    print(f"Total Requested Permissions: {len(result['permissions']['requested'])}")
    print("\nRequested Permissions:")
    for perm in result['permissions']['requested']:
        print(f"  - {perm}")
    
    print("\nInstall Permissions:")
    for perm, granted in result['permissions']['install'].items():
        print(f"  - {perm}: {'Granted' if granted else 'Not Granted'}")
    
    print("\nRuntime Permissions:")
    for perm, granted in result['permissions']['runtime'].items():
        print(f"  - {perm}: {'Granted' if granted else 'Not Granted'}")
    
    # 打印性能数据摘要
    print("\nPerformance Summary:")
    if result['performance_data']['cpu']:
        avg_cpu = sum(x['value'] for x in result['performance_data']['cpu']) / len(result['performance_data']['cpu'])
        max_cpu = max(x['value'] for x in result['performance_data']['cpu'])
        min_cpu = min(x['value'] for x in result['performance_data']['cpu'])
        print(f"CPU Usage:")
        print(f"  Average: {avg_cpu:.2f}%")
        print(f"  Maximum: {max_cpu:.2f}%")
        print(f"  Minimum: {min_cpu:.2f}%")
    
    if result['performance_data']['memory']:
        avg_memory = sum(x['value'] for x in result['performance_data']['memory']) / len(result['performance_data']['memory'])
        max_memory = max(x['value'] for x in result['performance_data']['memory'])
        min_memory = min(x['value'] for x in result['performance_data']['memory'])
        print(f"\nMemory Usage:")
        print(f"  Average: {avg_memory/1024:.2f} MB")
        print(f"  Maximum: {max_memory/1024:.2f} MB")
        print(f"  Minimum: {min_memory/1024:.2f} MB")
    
    # 生成性能图表
    plot_performance_data(result)
    print("\nPerformance charts have been saved to 'performance_analysis.png'")

if __name__ == "__main__":
    main()
