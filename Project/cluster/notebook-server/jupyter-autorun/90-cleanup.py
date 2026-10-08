import arkouda as ak

def cleanup_arkouda():
    
    if ak.is_connected():
        ak.disconnect()
        print("Disconnected from the Arkouda server.")
    else:
        print("Not connected to the Arkouda server.")