# Leashed
<img src="https://media.giphy.com/media/S8lbi2cusC5gVC0xOS/giphy.gif"/>
<br>
<p float="left">
  <img src="https://media.giphy.com/media/RKMMj20eRHONfImd0L/giphy.gif"/>
  <img src="https://media.giphy.com/media/S6Zdj4EiS99DlVZuDS/giphy.gif"/>
  <img src="https://media.giphy.com/media/d5qOvltp866jRzktDZ/giphy.gif"/>
</p>

Create a digital Leash between your Bluetooth Devices and your phone to avoid loss. Prevention > Recovery.
<br>
<h3>GOALS</h3>
<br>
I wanted to be able to track any Bluetooth device. This meant I had to implement a signal
recognition pairing step. This is required because some devices only have a MAC address,
they don't have a friendly name, and most users don't know their device has a mac address of
12:41:89:2a:51:... and so on…
<br>
Once I paired to a device I wanted to be able to track and notify the user when they
connected or disconnected from that Bluetooth device. If they were connected to the device I also
wanted to be able to let the user leash to it at a certain distance. The final step was to be able to
help the user find their device when they were connected to it because the device maybe in range but under a pile of clothing or under the bed.
<br>
<h3>BLUETOOTH DETAILS</h3>
<br>
A lot of little things made this project seem simple but actually be quite complicated. The
first of those is that the Bluetooth spec is massive and not really all that consistent, it's full of
edge cases.
<br>
The other is that the signal that Bluetooth device emits or the RSSI does not mean
anything standard. It very roughly approximates an unscaled proximity but it does so, so roughly, that its only usable within a short distance. And even then how an RSSI value tries to approximate
distance is not standard. So an RSSI value of -85 might indicate a distance of 4 meters away on
a device with a weaker emiter and 200 meters away on a device that has a stronger emitter.
<br>
The RSSI degradation pattern as you move away from it also make it clear the RSSI isn't
very helpful for long. It's only helpful for the first 10 to 25% of the device's max distance and after that the RSSI flatlines [on a distance vs rssi graph].
<br>
On top of that, the RSSI signal oscillates in a wave pattern that depends on the
specs of the device, the distance you are from the device, and the interference. Ideally, you
could remove this wave from the RSSI results but it would require the user to sit in place so you
could grab the wave pattern for that specific distance.
<br>
Yet another complication is that every environment is different at a different time in terms
of interference so the interference map of the current environment for every device at all points
is unknown although very important if you are trying to use the RSSI to estimate distance or
location.
<br>
Then you add to that that not every device emits at the same speed. Some devices will
emit 250 times in a minute, others only 25 times.
<br>
Then you can factor in the limitation of most Bluetooth receivers. They can only receive
signals sequentially and at a certain speed [atleast with the Bluetooth Library I was using]. So the more devices there are, they longer it might take to hear back from all of them. Additionally, you don't hear back from them in order, it's all random. Suppose you have 2 identical devices, device A and B. After 5 minutes you might hear back from A 200 times and from B only 100 even though they were in the exact same location with the same exact level of interference.
<br>
<h3>OTHERS RESEARCH</h3>
<br>
Others research primarily focused on locating the device's position. Ultimately what it
came down to is that this is really hard. Most people that attempted it used static Bluetooth
receiving towers with known positions and even then their results were not great. Partially
because they didn't keep in mind Bluetooth signal degradation and oscillation. The ones that
were partially successful were only so because they placed the static towers close enough to the bluetooth device so that the RSSI signal degradation problem was not an issue.
<br>
<h3>MY RESEARCH</h3>
<br>
After realizing the above I just wanted to see If it was possible for me to extend how far I
could usefully estimate a device's distance since it was clear that estimating position was
just a more complicated version of this problem. As discussed, using RSSI is only helpful for a
little while, then the RSSI starts flatlining. But as I was collecting data I realized that the further you got from the device the less often you received an emission. In other words the longer the
interval between emissions. So I combined this data and was able to successfully extend the
range by about 25%. In the future, I would like to extend this further by somehow being able to
extract the device's signal oscillation.
<br>
<h3>USING RESEARCH</h3>
<br>
So after this, I decided to try to find ways that I could use the research If I had unlimited
time. If I could map RSSI to distance the first thing I could do was determine If a change in
signal was due to an object that was causing or is causing interference. This is because human
walking speed is around 3 mph, jogging speed is around 6 mph, and running speed is around 9 mph. So if the signal jump indicates that the person was going 12 mph It becomes very likely the the signal
jumped as a cause of interference. And that can help the user find their device even faster. In
the long run, it might even be possible to use this to create a rough 3D image of the space and
place the object in the space.
<br>
Another way we can use interference for our benefit is by using our own bodies to create
interference to determine the heading of the device. If we are between the transmitter and
receiver the signal will be the lowest so If we simply ask the user to turn 90 degrees 4 times to
one side we will be able to tell them where the device is relative to them.
<br>
Additionally, because the RSSI signal is useful within a certain distance to estimate the
distance the receiver is from the Bluetooth signal transmitter; We can track changes in RSSI to tell the user if they are getting closer or further away from the device. By using rolling averages we can also indicate to the user if the slight signal drop or increase is due to signal oscillation mentioned previously or due to an actual change in signal strength. 
<br>
We would have 2 rolling averages, one that reacts to change faster and one that reacts to change slower. If the faster one crosses the slower one and it's now above the slower one we know our signal is increasing and the inverse is also true.
<br>
If we combine both of the above we can read in the signal and guide the user to the
location of the device. You determine the heading of the device, you head towards it, and when
you see the signal rise, then drop again, you know the user passed the device and the device is
perpendicular to them so you loop back around and determine the heading of the device and so
on.
<br>
  <h3>IMPLEMENTATION</h3>
<br>
I used flutter which was great for UI but caused a lot of problems when implementing everything else. The Bluetooth Libaray required a whole nother wrapper class to deal with its problems. Then the shift to android X caused a whole nother set of problems since sometimes the library itself was shifted over but not the ones it depended on. And finally, the way that dart encodes to JSON is broken, doing
nested toJson call should not break anything but it does so I had to make my own. All of these
delays added up to roughly 80 to 100 hours of work and are the reason I was not able to
complete the implementation.
<br>
I did get the chance to implement easy pairing. And I also got the chance to implement
an SOS mode that notified anyone on your emergency contacts when your device disconnected
from your phone and it was clear that you could not help yourself because if you would have
then you would have been able to stop the SOS countdown.
