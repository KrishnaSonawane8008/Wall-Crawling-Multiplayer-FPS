This was mad with Godot v4.2.1 stable
<br>
<h1>The Concept</h1>
This is a proof-of-concept for a multiplayer First Person Shooter where you play as a mechanical spider which can shoot lazers and can swing around and crawl around in the environment. The game rules are the same as traditional FPS games where the goal is to shoot the opponent, the twist is the it allows the player to use the entire environment as a traversable space hence providing a lot more freedom of movement. 
<br>
<br>
The players can walk on walls, arches, or really any surface on the map, in addition to that the players can also grappel to a close enough surface where normally, reaching via crawling would take time. All of these mechanics combined allow for player tricks which enhance the regular FPS experience.
<br>
<br>
You can get a glimpse at the gameplay below(sorry for bad quality, github doesn't allow very large videos, a better video can be seen <a href="/BetterQuality_GameplayVideo/Multiplayer_GameplayCompressed.mp4">here</a>):
<br>
<video src="https://github.com/user-attachments/assets/d8bdd78a-056b-49b3-b2c4-c5b9f8564214"></video>
<h1>How it Works</h1>
<h3>Player Movement</h3>
The gameplay movement is divided in two parts- The Movement on the Surface and The <a href="https://in.mathworks.com/discovery/inverse-kinematics.html">Inverse Kinematics</a> for animation of legs.
<br>
The movement on the surface is achieved by a method mentioned in one of my projects for mesh surface walking, it's explained in much more detail <a href="https://github.com/KrishnaSonawane8008/Walking-on-Mesh-Surface-in-Godot-4">here</a>.
<br>
<br>
Once the movement is implemented for the player model, grappling is just a case of the movement where the current face is changed to the one hit by a  raycast. Then the position of the player model is lerped from the current position to the one hit by the raycast and no other movement is allowed(except rotation) till the player reaches the hit face, giving the feeling of grappling from one point to other.
<br>
<br>
Now that the movement is setup, you can see how it looks without IK animation:
<br>
<video src="https://github.com/user-attachments/assets/a3c74757-a0c1-4306-8511-33f310394653"></video>
The movement looks stiff and is stuttering a bit when rotated, this is solved when animation is added to the legs of the spider model, this is done with the help of Inverse Kinematics.
<br>
<br>
<a href="https://in.mathworks.com/discovery/inverse-kinematics.html">Inverse Kinematics</a> is a method of animation of a system of connected "lines" which are connected via joints between every two sets of "lines"(these lines can be anything, rods, metal bars, robot parts, etc...).The main goal of Inverse Kinematics is to make this "arm", made by the connection of these "lines", reach from one position to another.
<br>
<br>
In our case these "lines" are the bones in the <a href="https://en.wikipedia.org/wiki/Skeletal_animation#:~:text=Skeletal%20animation%20or%20rigging%20is,or%20bones%2C%20and%20collectively%20forming">skeleton</a> used for <a href="https://www.youtube.com/watch?v=3RSwjZLClRc">rigging</a> our player model. The animation works by setting the current position of the end bone as the starting point and the next point on the walking surface(found by raycast collisions, more on this later) as the goal point, where the end bone is to place its tip. The IK process is made easy by the Godot 4 <a href="https://docs.godotengine.org/en/stable/classes/class_skeletonik3d.html">SkeletonIK3D</a> node.
<br>
<br>
Once the IK is setup, we can see how the player movement is made more smooth(bad quality because of compression):
<video src="https://github.com/user-attachments/assets/f2671e44-a1d7-4f41-b797-b92c8922537e"></video>
<h3>Improving IK</h3>
As i mentioned before, that the next point on the walking surface is found by getting a raycast collision with the walking surface. The quality of the IK animation depends on the quality of the found collision point. For example, i first had the idea of using straight raycasts to get the collision points but this provided bad inputs when the player was standing on sharply curved surfaces because of these sharp angles, the raycasts were missing a lot and the IK animation was looking bad.
<br>
<br>
To solve this problem, i chose to use my <a href="https://github.com/KrishnaSonawane8008/Multi-Directional-Raycast-Plugin-for-Godot-4">MultiJoint_Raycast plugin</a> which allowed me to curve the raycasts as i wished. Now these curved raycasts have a very low chance of missing the surface instead of the strainght variant which missed the surface when moving on sharp cornered surfaces.
<br>
<br>
You can see below, how i used the plugin with the player model:
<video src="https://github.com/user-attachments/assets/eea75b1e-2c67-4423-ad4a-ebbcd8b74239"></video>
<h3>Multiplayer in Godot</h3>
Godot provides its own multiplayer API, info about which can be found in the documentation. I would reading some of these:
<br>
<li>High-level multiplayer :- https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html </li>
<br> 
<li>MultiplayerAPI :- https://docs.godotengine.org/en/stable/classes/class_multiplayerapi.html </li>
<br> 
<li>ENetMultiplayerPeer :- https://docs.godotengine.org/en/stable/classes/class_enetmultiplayerpeer.html </li>
<br> 
<li>MultiplayerPeer :- https://docs.godotengine.org/en/stable/classes/class_multiplayerpeer.html </li>
<br>
<br>
If you want to go through a basic setup tutorial, i would recommend these videos:
<br>
<li>FinePointCGI :- https://www.youtube.com/watch?v=e0JLO_5UgQo&t=0s</li>
<br>
<li>DevLogLogan :- https://www.youtube.com/watch?v=n8D3vEx7NAE&t=0s</li>