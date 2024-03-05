import subprocess
from time import localtime, sleep

###########################################################################
## This section can be used if you want to use netstat instead of lsof ##
## It will not show the process, only ip info                          ##
###########################################################################


def parse_port(address):
    last_dot_index = address.rfind('.')
    return {
        'address': address[:last_dot_index],
        'port': address[last_dot_index + 1:]
    }

def parse_pid(pid_entry):
    #TODO: lookup pid and return user and process using it ps aux | awk -v pid=712 '$2 == pid'
    t_info = subprocess.run(["ps", "aux"], capture_output=True, text=True)
    for line in t_info.stdout.split('\n'):
        columns = line.split()
        if columns[1] == pid_entry:
            return {
                'user': columns[0],
                'started': columns[8],
                'time': columns[9],
                'command': columns[10],
            }
    else:
        return {
            'user': "None",
            'started': "None",
            'time': "None",
            'command': "None",
        }

def pretty_print_netstat(entry_data):
        connections = entry_data['data']
        print("======================================================")
        print("Protocol: {0}".format(connections['protocol']))
        print("Local Address: {0}".format(connections['local_address']))
        print("Local Port: {0}".format(connections['local_port']))
        print("Foreign Address: {0}".format(connections['foreign_address']))
        print("Foreign Port: {0}".format(connections['foreign_port']))
        print("Foreign Port: {0}".format(connections['state']))
        print("PID: {0}".format(connections['pid']))
        print("User: {0}".format(connections['user']))
        print("Start Time: {0}".format(connections['started']))
        print("Execution Duration: {0}".format(connections['time']))
        print("Executed Command: {0}".format(connections['command']))
        print("\n\n")

def get_active_connections():

    network_connections = subprocess.run(["netstat", "-anv"], capture_output=True, text=True)
    active_connections = []
    try:
        for line in network_connections.stdout.split('\n'):
            if 'ESTABLISHED' in line:
                columns = line.split()
                local_addr = parse_port(columns[3])
                foreign_addr = parse_port(columns[4])
                app_info = parse_pid(columns[8])
                connection_info = { 
                'local_port': local_addr['port'], 
                    'data': {
                        'protocol': columns[0],
                        # 'recv_q': columns[1],
                        # 'send_q': columns[2],
                        'local_address': local_addr['address'],
                        'local_port': local_addr['port'],
                        'foreign_address': foreign_addr['address'],
                        'foreign_port': foreign_addr['port'],
                        'state': columns[5],
                        'pid': columns[8],
                        'user': app_info['user'],
                        'started': app_info['started'],
                        'time': app_info['time'],
                        'command': app_info['command'],
                    }
                }
                active_connections.append(connection_info)
        return active_connections
    except subprocess.CalledProcessError as exception:
        print("Error {0}".format(exception))


def monitoring(connections):
    if connections:
        for connection_info in connections:
            pretty_print_netstat(connection_info)
    else:
        print("No connections found.")
        exit(1)
    start_monitoring = input("Do you want to monitor this current state? [y/n]")
    if start_monitoring.lower() == "y" or start_monitoring.lower() == "yes":
        print("Starting to monitor connections")
        while True:
            try:
                new_connections_list = []
                old_connections_list = []
                new_connections = get_active_connections()
                if new_connections is None:
                    print("Empty new connections")
                    exit(1)
                for entry in new_connections:
                    new_connections_list.append(entry['local_port'])
                for entry2 in connections:
                    old_connections_list.append(entry2['local_port'])
                not_in_second_list = [entry for entry in new_connections_list if entry not in old_connections_list]
                for item in not_in_second_list:
                    matching_entry = next((entry for entry in new_connections if entry['local_port'] == item), None)
                    if matching_entry:
                        pretty_print_netstat(matching_entry)
                        connections.append(matching_entry)
                sleep(1)
            except KeyboardInterrupt:
                print("\nCtrl+C Detected. Goodbye!")
                exit(1)

def geolocation(connections):
    full_data = []
    blacklist = ['1.1.1.1', '1.0.0.1', '127.0.0.1', '127.0.1.1']
    for item in connections:
        if item not in blacklist:
            # Up to 10,000 free requests per month
            specific = "https://ipwho.is/" + item['data']['foreign_address']
            # TODO: Here
            location_data = subprocess.run(['curl', specific], capture_output=True, text=True)
            item['data']['latitude'] = location_data['latitude']
            item['data']['longitude'] = location_data['longitude']
            full_data.append(item)
    return True
###########################################################################
## This section will display a lot more info                           ##
## It will not show the process, only ip info                          ##
###########################################################################

#
# def parse_addr(address):
#     local_address, foreign_address = address.split('->')
#     local_ip, local_port = local_address.split(':')
#     foreign_ip, foreign_port = foreign_address.split(':')
#     return {
#         'l_ip': local_ip,
#         'l_port': local_port,
#         'f_ip': foreign_ip,
#         'f_port': foreign_port
#     }
#
#
# def get_active_connections():
#
#     network_connections = subprocess.run(["sudo", "lsof", "-i", "-n", "-P"], capture_output=True, text=True)
#
#     active_connections = []
#     try:
#         for line in network_connections.stdout.split('\n'):
#             if 'ESTABLISHED' in line:
#                 columns = line.split()
#                 parsed_addr_info = parse_addr(columns[8])
#                 connection_info = {
#                     'app': columns[0],
#                     'pid': columns[1],
#                     'user': columns[2],
#                     'ipV': columns[4],
#                     'protocol': columns[7],
#                     # 'recv_q': columns[1],
#                     # 'send_q': columns[2],
#                     'local_address': parsed_addr_info['l_ip'],
#                     'local_port': parsed_addr_info['l_port'],
#                     'foreign_address': parsed_addr_info['f_ip'],
#                     'foreign_port': parsed_addr_info['f_port'],
#                     # 'state': columns[5],
#                 }
#                 active_connections.append(connection_info)
#         return active_connections
#     except subprocess.CalledProcessError as exception:
#         print("Error {0}".format(exception))
#
#
#
# def monitoring(connections):
#     if connections:
#         for connection_info in connections:
#             print("======================================================")
#             print("Application: {0}".format(connection_info['app']))
#             print("PID: {0}".format(connection_info['pid']))
#             print("User: {0}".format(connection_info['user']))
#             print("IP Version: {0}".format(connection_info['ipV']))
#             print("Protocol: {0}".format(connection_info['protocol']))
#             print("Local Address: {0}".format(connection_info['local_address']))
#             print("Local Port: {0}".format(connection_info['local_port']))
#             print("Foreign Address: {0}".format(connection_info['foreign_address']))
#             print("Foreign Port: {0}".format(connection_info['foreign_port']))
#             print("\n\n")
#         start_monitoring = input("Do you want to monitor this current state? [y/n]")
#     else:
#         print("No connections found.")
#         exit(1)
#     if start_monitoring.lower() == "y" or start_monitoring.lower() == "yes":
#         print("Starting to monitor connections")
#         while True:
#             try:
#                 new_connections = get_active_connections()
#                 if new_connections is None:
#                     print("Empty new connections")
#                     exit(1)
#                 for conn in new_connections:
#
#                     # print(conn)
#                     if conn not in connections:
#                         print(conn)
#                         connections.append(conn)
#                 sleep(1)
#             except KeyboardInterrupt:
#                 print("\nCtrl+C Detected. Goodbye!")
#                 exit(1)

# def geolocation(connections):
#     return True

def main():
    connections = get_active_connections()
    # Check if empty
    mode = input("Would you like to enter monitoring mode or geolocation? [m/g]")
    if mode.lower() == "m" or mode.lower() == "monitoring":
        monitoring(connections)
    elif mode.lower() == "g" or mode.lower() == "geolocation" or mode.lower() == "geo":
        geolocation(connections)
    else:
        print("Sorry, {0} is not a recognized command.".format(mode))


main()
