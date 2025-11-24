# Android Device Testing Guide

This guide explains how to run the Dayaw app on a **real Android device** instead of using a web browser or emulator.

## Prerequisites

1. **Flutter SDK** installed on your development machine
2. **Android device** with USB debugging enabled
3. **USB cable** to connect your device to your computer
4. **Same network** - Your device and computer must be on the same Wi-Fi network (for API connectivity)

## Step 1: Find Your Computer's Local IP Address

The Android device needs to connect to the backend server running on your development machine. You'll need your computer's local network IP address.

### On Windows:
```bash
ipconfig
```
Look for **IPv4 Address** under your active network adapter (usually starts with `192.168.x.x` or `10.0.x.x`)

### On macOS:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```
Or go to: **System Preferences → Network → Select your connection → Advanced → TCP/IP**

### On Linux:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```
Or:
```bash
hostname -I
```

**Example IP addresses:**
- `192.168.1.100`
- `192.168.100.168`
- `10.0.0.5`

> ⚠️ **Important:** Do NOT use `localhost` or `127.0.0.1` - these only work on the same device!

## Step 2: Configure the API Endpoint

1. Open the file: `frontend/lib/config/app_config.dart`

2. Update the `apiBaseUrl` with your computer's IP address:

```dart
class AppConfig {
  // Replace 192.168.100.168 with YOUR computer's IP address
  static const String apiBaseUrl = 'http://192.168.1.100:5000';
  // ...
}
```

**Example configurations:**
```dart
// If your computer's IP is 192.168.1.100
static const String apiBaseUrl = 'http://192.168.1.100:5000';

// If your computer's IP is 10.0.0.5
static const String apiBaseUrl = 'http://10.0.0.5:5000';
```

## Step 3: Configure the Backend Server

The Flask backend needs to listen on all network interfaces (not just localhost) so your Android device can connect to it.

1. Open the file: `backend/app.py`

2. Find the section at the end of the file where the Flask app runs (usually looks like):
```python
if __name__ == "__main__":
    app.run(debug=True)
```

3. Update it to listen on all interfaces:
```python
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
```

> 📝 **Note:** `host='0.0.0.0'` means the server will accept connections from any network interface, making it accessible from your Android device on the same network.

## Step 4: Configure Your Firewall

Make sure your computer's firewall allows incoming connections on port 5000.

### Windows Firewall:
1. Open **Windows Defender Firewall**
2. Click **Advanced settings**
3. Click **Inbound Rules** → **New Rule**
4. Select **Port** → **TCP** → **Specific local ports: 5000**
5. Select **Allow the connection**
6. Apply to all profiles (Domain, Private, Public)
7. Name it "Flask Dev Server" and finish

### macOS Firewall:
1. Go to **System Preferences → Security & Privacy → Firewall**
2. Click **Firewall Options**
3. Add Python to allowed applications

### Linux (UFW):
```bash
sudo ufw allow 5000/tcp
```

## Step 5: Enable USB Debugging on Your Android Device

1. Open **Settings** on your Android device
2. Go to **About Phone**
3. Tap **Build Number** 7 times to enable Developer Options
4. Go back to **Settings → Developer Options**
5. Enable **USB Debugging**
6. Connect your device to your computer via USB
7. Accept the USB debugging authorization on your device

## Step 6: Start the Backend Server

In your terminal, navigate to the backend directory and start the Flask server:

```bash
cd backend
python app.py
```

You should see output like:
```
* Running on http://0.0.0.0:5000
* Running on http://192.168.1.100:5000
```

> ✅ **Verify:** The second line shows your local network IP. This should match what you configured in Step 2.

## Step 7: Build and Run on Android Device

In a new terminal, navigate to the frontend directory and run:

```bash
cd frontend
flutter devices
```

You should see your connected Android device listed. Then run:

```bash
flutter run
```

Or select your device in your IDE and click Run.

## Step 8: Test the Connection

1. Open the Dayaw app on your Android device
2. Try accessing features that use the API (e.g., Alaala, Salita, Sulatin)
3. Check for successful data loading

### Troubleshooting Connection Issues:

If you get connection errors:

1. **Verify both devices are on the same Wi-Fi network**
   - Check your computer's Wi-Fi connection
   - Check your Android device's Wi-Fi connection
   - They should be connected to the same network

2. **Test the connection manually:**
   - On your Android device, open a web browser
   - Go to: `http://YOUR_IP:5000/api/db-ping` (replace YOUR_IP)
   - You should see a JSON response like: `{"ok": true, "message": "..."}`

3. **Check the backend server logs:**
   - Look at your terminal running `python app.py`
   - You should see incoming requests when you use the app

4. **Verify the IP address:**
   - Make sure you're using your actual local network IP
   - NOT `localhost` or `127.0.0.1`
   - NOT your public internet IP

5. **Restart everything:**
   - Stop the backend server (Ctrl+C)
   - Restart it: `python app.py`
   - Stop the Flutter app
   - Run: `flutter run` again

## Alternative: Testing via Wi-Fi (Without USB)

After Step 5, you can connect wirelessly:

1. Make sure USB debugging is enabled
2. Connect via USB initially
3. Run: `adb tcpip 5555`
4. Find your device's IP: **Settings → About Phone → Status → IP address**
5. Disconnect USB cable
6. Run: `adb connect YOUR_DEVICE_IP:5555`
7. Run: `flutter run`

## Quick Reference: Configuration Files

### Primary Configuration File
**File:** `frontend/lib/config/app_config.dart`
- Update `apiBaseUrl` with your computer's IP address

### Files Using Configuration (Automatically Updated)
- `frontend/lib/services/api_service.dart` - Main API service
- `frontend/lib/services/sulatin_api.dart` - Sulatin (handwriting) API

> 💡 **Pro Tip:** You only need to change the IP in `app_config.dart` - all services will automatically use the new configuration!

## Common Issues and Solutions

### Issue: "Connection refused" or "Failed to connect"
**Solution:** 
- Verify backend server is running
- Check firewall settings
- Ensure both devices are on the same network
- Verify IP address is correct

### Issue: "Connection timed out"
**Solution:**
- Check if backend server is running on `0.0.0.0:5000`
- Verify firewall allows port 5000
- Try pinging your computer from Android device

### Issue: "No device found" when running flutter run
**Solution:**
- Reconnect USB cable
- Restart adb: `adb kill-server && adb start-server`
- Check USB debugging is enabled
- Try a different USB port or cable

### Issue: App builds but API calls fail
**Solution:**
- Verify `apiBaseUrl` in `app_config.dart` matches your computer's IP
- Test the URL in a browser on your Android device
- Check backend server logs for errors

## Best Practices

1. **Use a static IP** for your development machine to avoid reconfiguring frequently
2. **Keep backend server running** while testing
3. **Monitor backend logs** to debug API issues
4. **Test on different networks** to ensure it works in various environments
5. **Document your IP** for team members if working collaboratively

## Switching Between Environments

### For Web/Emulator Testing:
```dart
static const String apiBaseUrl = 'http://localhost:5000';
```

### For Android Device Testing:
```dart
static const String apiBaseUrl = 'http://192.168.1.100:5000'; // Your computer's IP
```

### For Production:
```dart
static const String apiBaseUrl = 'https://your-production-api.com';
```

## Security Note

⚠️ **Warning:** Running the backend on `0.0.0.0` makes it accessible to anyone on your local network. This is fine for development but:
- Don't use this configuration in production
- Don't run on public networks (coffee shops, airports, etc.)
- Use this only on trusted private networks

## Additional Resources

- [Flutter Documentation - Android Setup](https://docs.flutter.dev/get-started/install)
- [Flutter Documentation - Deployment](https://docs.flutter.dev/deployment/android)
- [Flask Documentation - Deployment](https://flask.palletsprojects.com/en/latest/deploying/)

## Support

If you encounter issues:
1. Check this guide thoroughly
2. Review backend server logs
3. Test API endpoints manually in a browser
4. Verify network connectivity
5. Check Flutter and Dart SDK versions

---

**Happy Testing! 🎉**
