module MyModule::WearableSync {
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing a wearable device's sync data
    struct DeviceData has store, key {
        device_id: u64,           // Unique device identifier
        last_sync_time: u64,      // Timestamp of last synchronization
        step_count: u64,          // Total step count from device
        heart_rate: u64,          // Last recorded heart rate (BPM)
        battery_level: u8,        // Battery percentage (0-100)
        sync_count: u64,          // Number of times device has synced
    }

    /// Function to register a new wearable device
    public fun register_device(
        owner: &signer, 
        device_id: u64, 
        initial_steps: u64, 
        initial_heart_rate: u64,
        initial_battery: u8
    ) {
        let device_data = DeviceData {
            device_id,
            last_sync_time: timestamp::now_seconds(),
            step_count: initial_steps,
            heart_rate: initial_heart_rate,
            battery_level: initial_battery,
            sync_count: 1,
        };
        move_to(owner, device_data);
    }

    /// Function to synchronize device data with updated metrics
    public fun sync_device_data(
        owner: &signer,
        new_steps: u64,
        new_heart_rate: u64,
        new_battery: u8
    ) acquires DeviceData {
        let device_data = borrow_global_mut<DeviceData>(signer::address_of(owner));
        
        // Update device metrics
        device_data.step_count = device_data.step_count + new_steps;
        device_data.heart_rate = new_heart_rate;
        device_data.battery_level = new_battery;
        device_data.last_sync_time = timestamp::now_seconds();
        device_data.sync_count = device_data.sync_count + 1;
    }

    
    #[view]
    public fun get_device_data(owner_address: address): (u64, u64, u64, u64, u8, u64) acquires DeviceData {
        let device_data = borrow_global<DeviceData>(owner_address);
        (
            device_data.device_id,
            device_data.last_sync_time,
            device_data.step_count,
            device_data.heart_rate,
            device_data.battery_level,
            device_data.sync_count
        )
    }
}