---
title: Single Sensor Memoryless Trail Following Automatas
author: Marcell Jose Vazquez-Chanlatte
college: Computer Science
school: University of Illinois
mathjax: on
abstract: |
    This paper presents Single Sensor Memoryless Trail Following Automatas. It develops a formal model of the dynamics of such automata, the trails it follows, as well as exploring when these automata can be expected to halt. The halting conditions involve restrictions in the topology, geometry, boundaries of the trail, and physical considerations. The memoryless restriction distinguishes this approach from other stateful techniques used to map out environments. Lastly, the approach focuses on the dynamics rather the kinematics, both aligning better with the actual controls of physical robots and directly allowing perturbations in the motions due to uneven friction, forcing, or inclination.
---


# Motivation

![]( images/OnPath.png)

The memoryless single sensor "line" following automata is among the first robotics projects
students encounter (indeed this author has encountered numerous variations[^6]). When encountering 
a boundary, the robot reacts to correct its course and carries on. However, as is often the case, 
implementation is vastly easier than formal modeling and verification 
of the problem.
While not having a memory to map out and record the boundaries of the "line"
simplifies the algorithm's implementation, as we shall see, without proper care the non-linear dynamics of these
automata are easily subject to deterministic chaos. Even after carefully
constructing our hybrid automata to have easily computable (and trivially simulatable dynamics), 
we find that chaos still emerges. Simulation based verification for some trails becomes a
futile task. Nevertheless, many practical and physical trails remain approachable both from
analytic and simulation based perspective.

As one might expect, simple path following automata are very well studied, particularly in
the context of mapping [@disk-explore]. But such automata and many like it, exploit
memory to make deliberate decision for path planning, eliminating many of the interesting nuances that 
lead to unstable blowup in the model. Furthermore, many
path following robots are gifted with comparatively richer sensor arrays. Indeed, 
tasks that may prove trivial given even one additional sensor, become unfeasible
in general case[^7]. Lastly, much of the compared literature focuses on the kinematics rather
than the dynamics of the robot. The approach here focuses on the dynamics which both aligns
better with the actual controls of physical robots, and more directly allows perturbations in 
the motions due to uneven friction, forcing, or inclination.

## Line vs Path vs Trail

In the course of studying this problem, to avoid collision with other nomenclature in topology and 
geometry, this author settled upon trail for describing what might otherwise commonly be refereed
to as a line or a path. We shall expand on the precise nature of trails later, but for now the simple
intuitions one might have shall suffice.

# Dynamics vs Kinematics

The focus of many path planning algorithms [@planning_steven] tend to focus on kinematic approaches 
such as dubins path [@Dubins]. While these provide nice abstractions for focusing on the algorithms,
robots are inevitably controlled through dynamics such as torque on the wheels. The dynamics approach
better supports directly modeling the environment (and how slight deviations from the model might affect
the resulting kinematics).

# Dynamics
![Robot Diagram](images/roomba.png)

## Conservative Dynamics

The robot, approximated as a cylinder, has mass $m$, radius $r$ and 
height $h$. The moment of inertia about its principle axis, $\hat{z}_{robot}$,
is $I = \frac{1}{2}mr^2$. 

There are $3$ degrees of freedom, $x, y, \theta$. $z$ serves as a potential field
$V(x,y, \theta) = mgz(x, y)$, while $x$ and $y$ define its absolute coordinates and
$\theta$ provides orientation on a 2-d manifold.

Therefore, the Lagrangian[^1] is given by:

> $\mathcal{L} = \frac{m}{2}\left((\dot{x}^2+\dot{y}^2) + \frac{1}{2}r^2 
> \dot{\theta}^2 - g\cdot z(x, y)\right)$

## Non-Conservative Dynamics

Next, let us consider the forces and torques exerted on the robot.
There are 2 forces, $(F_l, F_r)$, located at the wheels, which themselves are 
located at $(0, r_w)$ and $(\pi, r_w)$ in the robot's local coordinate system.
Thus, there is a net force on the center of mass $F_l + F_r$ as well as a net
torque $F_r r_w - F_l r_w = (F_r - F_l)r_w$ about $\hat{z}_{\text{robot}}$.

Furthermore, the wheel's rotation produces friction, presumably proportional to
the speed of rotation. One observes that friction is velocity dependent which 
is conveniently assumed to be proportional the net speed of the wheel. The net
velocity of the wheels is the velocity of the center of mass plus the speed 
on the radius in the local coordinates.

> $v_{wr}= \hat{x}[\dot{x} - \dot{\theta} r_w \sin(\theta)] + \hat{y}[\dot{y}
> + \dot{\theta} r_w \cos(\theta)]$
>
> $v_{wl}= \hat{x}[\dot{x} + \dot{\theta} r_w \sin(\theta)] + \hat{y}[\dot{y}
> - \dot{\theta} r_w \cos(\theta)]$
  
Note that if we take the force due to the left and right wheels to be: 
$F = F_{wl} + F_{wr} \propto - \vec{v}$, then the rotational terms 
($\propto \dot{\theta}$) of the force cancel leaving $F_{w} \propto 
-2(\hat{x}\dot{x} +\hat{y}\dot{y})$. Similarly, the torque becomes 
$\tau_w = -r_w |(F_{wr} - F_{wl})| \propto -2 r_w^2 \dot{\theta}$.

## Governing Differential Equations

Applying Euler-Lagrange and introducing the forcing

> $\left[\begin{matrix}\ddot{x} + \gamma\dot{x} - g \cdot \delta_x z\\
> \ddot{y} + \gamma\dot{y} - g\cdot \delta_y z \\
> \ddot{\theta}+\gamma (r_w / r)^2 \dot{\theta}\end{matrix}\right] = 
> \frac{1}{m}\left[\begin{matrix}(F_r + F_l)\cos(\theta)\\
> (F_r + F_l)\sin(\theta) \\(F_r - F_l)(r_w/r^2)
> \end{matrix}\right]$

Or putting into a standard form:

> $\left[\begin{matrix}
> \dot{x}\\
> \dot{y}\\
> \dot{\theta}\\
> \dot{v_x}\\
> \dot{v_y}\\
> \dot{v_{\theta}}
> \end{matrix} \right ] \equiv
> \left[\begin{matrix}
> \dot{\mathbf{x}}\\
> \dot{\mathbf{v}}
> \end{matrix} \right ] = f(F_r, F_l, \mathbf{x}, \mathbf{v})$

> $\equiv \left [\begin{matrix}
> v_x\\
> v_y\\
> v_{\theta}\\
> -\gamma v_x + g \cdot \delta_x z\\
> -\gamma v_y + g \cdot \delta_y z\\
> -\gamma (r_w /r )^2 v_{\theta}\\
> \end{matrix}\right] +
> \frac{1}{m}\left [\begin{matrix}
> 0\\
> 0\\
> 0\\
> (F_r + F_l)\cos(\theta)\\
> (F_r + F_l)\sin(\theta)\\
> (F_r - F_l)(r_w/r^2)
> \end{matrix}\right]$

For convenience in the automata below, $\dot{\mathbf{a}} \equiv \left[\begin{matrix} \dot{\mathbf{x}}\\
 \dot{\mathbf{v}} \end{matrix} \right ]$

# Trail Following Automata

![Model with implicit velocity sensor](images/model1.png)

In this section I shall propose a hybrid automata model (illustrated in fig 3) for our trail following robot.
To derive the automata consider the following pseudo code for controlling the high level kinematics of the 
trail following robot.

      While Not on Goal
           If Robot On Trail
           Then Advance Forward
           Else
               Stop
               Find Trail by Rotating
               Stop

We can see the following 4 states:

1. Goal State: Implicit in the figure, at this state the system halts

2. Drive State: Given that the sensor says its on the trail (denoted HIT), the robot
should move forward. Here presumably the wheels rotate the same direction at 
the same speed (with the implied same forcing given our dynamics). This should continue 
until no longer on the trail (sensor reads a MISS).

3. Stop State: Finally, because the for the dynamics for robot disallow instantaneous stopping, 
the stop state serves to model the robots movements once forcing is no longer applied until
its kinetic energy is zero. This assertion is the same as imposing a guard on transitions
from the state insisting that $\mathbf{v} = 0$.

4. Turn State: The implied objective is to turn the robot in place such that the sensor lies
over the trail. That said, which way should the robot turn? To avoid over rotating due to 
rotating away from the trail (reversing the orientation of the robot), the robot shall
perform a breadth first style search by alternatively rotating at some angle $\alpha_i$
from its current heading, and then rotating $-2 \alpha_i$. Then perform the same procedure
for $\alpha_{i + 1}$. If $\alpha_{i}$ is strictly increasing, with sufficiently small differences
between successive alphas, then the robot is guaranteed not to over rotate.[^8] Note however that
our robot cannot make angle measurements directly, instead a rotation time $\Delta$, is defined.
The next $\Delta$ in the series is twice the original + a corrective term determined by the
time it takes to get $v_{\theta \text{max}}$ (which is as we shall later see is determined by $F_0$).
Next there is the matter of how to toggle directions. For that, a toggle variable, $s \in \{-1, 1\}$ is
employed. After the turning time has run out, $s := -s$ toggles the direction of turning. Turning
in place is then simply a matter of setting $F_r := -F_l := -s F_0 /2$


Finally, for convenience in the analytic analysis, quiescent initial conditions are assumed.


## Implicit velocity sensor

![No velocity sensor](images/model2.png)

One issue with the current model is it implies the existence of a velocity 
sensor (in the $|\mathbf{v}| = 0$ guard on leaving the stop state). Note 
however that because the stop time is not forced (and the system presumably
loses energy from friction) it is bounded by $T$ [^4]. For such systems, the time is given
by the impulse responses (see the dynamics during stop section for more)$.

### Specialization to flat terrains

While in search an analytic solution to system, we shall specialize to a flat 
terrain such that $\nabla z(x, y) = \mathbf{0}$. More complicated analytic
solutions are left as a potential future contribution.

## Dynamics during stop

If $z$ is independent of $x$ and $y$ then this reduces to 3 homogeneous linear
differential equations. The end boundary condition is $\mathbf{v}(t=t_f) = 0$.

> $F_r = F_l = 0\\\\
> \implies
> f = \left [\begin{matrix} v_x\\ v_y\\ v_{\theta}\\
> -\gamma v_x + g \cdot \delta_x z\\
> -\gamma v_y + g \cdot \delta_y z\\
> -\gamma (r_w /r )^2 v_{\theta}\\
> \end{matrix}\right] \\\\\\
> \implies
> diag(\left[\begin{matrix} 
> \delta_x^2 + \gamma \delta_x\\
> \delta_y^2 + \gamma\delta_y\\
> \delta_{\theta}^2 + \gamma (r_w / r)^2 \delta_{\theta}\end{matrix}\right])
> \left[\begin{matrix} x\\ y\\ \theta \end{matrix}\right] = 0$

Which have solutions (assuming w.l.o.g ($x(0)=y(0)=\theta(0)=0$):

> $x(t) = \left( 1 - e^{-\gamma t}\right) \dot{x}(0) \gamma^{-1}$

> $y(t) = \left( 1 - e^{-\gamma t}\right) \dot{y}(0) \gamma^{-1}$

> $\theta(t) = \left( 1 - e^{-(\gamma (r_w / r)^2) t}\right) \dot{\theta}(0) (\gamma (r_w / r)^2)^{-1}$

## Dynamics during drive

Because the stop state assures $\mathbf{v} = 0$ before transitioning to any 
state and there is no net torque by construction,e $\theta$ is fixed in the
drive state. If $z$ is independent of $x$ and $y$ then this reduces to the
following system linear differential equations:

> $F_r = F_l = \frac{1}{2}F_0 \wedge \mathbf{v}(t=0) = 0\\\\
> \implies
> f = \left [\begin{matrix} v_x\\ v_y\\ v_{\theta}\\
> -\gamma v_x + g \cdot \delta_x z\\
> -\gamma v_y + g \cdot \delta_y z\\
> -\gamma (r_w /r )^2 v_{\theta}\\
> \end{matrix}\right] +
> \frac{F_0}{m}\left [\begin{matrix}
> 0\\ 0\\ 0\\ \cos(\theta)\\ \sin(\theta)\\ 0
> \end{matrix}\right]\\\\\\
> \implies diag (\left [\begin{matrix}
> \delta_x^2 + \gamma \delta_x\\
> \delta_y^2 + \gamma \delta_y
> \end{matrix} \right ]) \left [\begin{matrix} x\\ y \end{matrix} \right ] =
> \frac{F_0}{m} \left [\begin{matrix} \cos{\theta} \\ \sin{\theta} \end{matrix} \right ]$

Which has the solution:

> $x{\left (t \right )} = C_{1} + C_{2} e^{- \gamma t} + \frac{t}{\gamma}(\frac{F_0}{m}\cos{\theta})$

> $y{\left (t \right )} = C_{3} + C_{4} e^{- \gamma t} + \frac{t}{\gamma}(\frac{F_0}{m}\sin{\theta})$

Which given $\dot{x}(0) = 0$ and w.o.l.g $x(0) = y(0)= 0$ yields

> $C_2 = -C_1 = (\frac{F_0}{m}\cos{\theta})\gamma^{-2}$

> $C_4 = -C_3 = (\frac{F_0}{m}\sin{\theta})\gamma^{-2}$

Rewriting in terms of $C_2$ and $C_4$

> $x(t) = C_2 (-1 + e^{-\gamma t} + \gamma t)$

> $y(t) = C_4 (-1 + e^{-\gamma t} + \gamma t)$

## Dynamics during turn

Again, the starting boundary condition for $\mathbf{v}(t=0) =0$. Thus, because
there is no $(x, y)$ forcing, $(x, y)$ are fixed during this state. Assuming
an $(x,y)$ independent $z$, this leaves a single linear differential equation
for $\theta$.

> $F_r = - F_l = s\cdot \frac{1}{2}F_0 \wedge \mathbf{v}(t=0) = 0\\\\
> \implies
> f = \left [\begin{matrix} v_x\\ v_y\\ v_{\theta}\\
> -\gamma v_x + g \cdot \delta_x z\\
> -\gamma v_y + g \cdot \delta_y z\\
> -\gamma (r_w /r )^2 v_{\theta}\\
> \end{matrix}\right] +
> \frac{s r_w F_0}{2 m r^2}\left [\begin{matrix}
> 0\\ 0\\ 0\\ 0\\ 0\\ 1
> \end{matrix}\right] \\\\\\
> \implies \left (\delta_{\theta}^2 + \gamma (r_w / r)^2 \delta_{\theta}\right )\theta =
> (s r_w F_0)/(2 m r^2)$

Applying the same techniques used in the dynamics during drive section, substituting

> $x(t) \rightarrow \theta(t)$

> $\gamma \rightarrow \gamma (r_w/r)^2 \equiv \gamma'$

> $(F_0/m)\cos(\theta) \rightarrow (s r_w F_0)/(2 m r^2)$

Yields

> $\theta(t) = C (-1 + e^{-\gamma' t} + \gamma' t)$

> $C = \frac{s r_w F_0}{2 m r^2}\gamma'^{-2}$

## Recap

In summary, so far we have defined a HIOA for our memoryless single 
sensor trail following robot. The model was carefully engineered such that
the dynamics in each state are _exactly_ known. In theory then, given a fixed
trail, it is possible to compute with 100% accuracy the trajectory of the automata.

As such, has the problem been in essence been entirely solved? In some sense yes,
if given a _specific_ instance of a finite trail. But in a practical and more 
general sense, perhaps not. For instance, when do the MISS and HIT actions actually occur?
Without some structure imposed, even if the state trajectories themselves are stable,
determining any non-trivial properties about the motion of the robot proves futile.

Presumably the HIT/MISS actions occur when the robot's sensor is over the trail, but that 
is hardly encoded in the automata. When analyzing a specific trail, we instead replace HIT 
and MISS with functions, where the signature of hit is $HIT: \mathbb{R}^3 \rightarrow \{0, 1\}$
and $MISS = \neg HIT$. As we shall see, one's intuition as to was a trail is restricts
the geometry and topology of a Trail.

# Definition of a Trail $\mathcal{T}$ and Goal state $\mathcal{G}$

## What makes for a good trail

![3x3 grid of trails](images/paths.png )

First let us address the question as to what exactly is a trail. 
As mentioned in the motivation section, we shall focus on trails
that are fixed with respect to the configuration space. Specifically,
given any configuration of the system, the set $\mathcal{T}$ will remain 
unchanged.

Furthermore, we shall see that given a specific trail, we shall see that the 
restrictions on the robot's dynamics are either straight forward and robust 
or subtle and HIGHLY sensitive to perturbations.

## Examination of example trails

### Vacuous goal states

Let us first examine trail 8. While the scale is ambiguous, it is implied to 
be very small (specifically, smaller than the robot). Here we have 2 options,
1 is to define an implicit goal/termination state when the robot completes a
360° turn. This can be implemented using a maximum timed allowed for
rotation. The other approach is to disallow such trails. We shall take the former 
approach. This will further motivate our introduction of invariant #1.

### $\mathcal{T} \cap \mathcal{G} \neq \emptyset$

Next let us consider trail 9. Here there is no goal state indicated. Such
configurations shall be disallowed by $\mathcal{T} \cap \mathcal{G} \neq
\emptyset$, where $\mathcal{G}$ is the set of goal states.

### $\mathcal{T} \subset R^2$

Examining all the trails, another property that emerges is that trails are
subset of $R^2$. While in principle they could be subsets of $R^{n\geq2}$,
because the robots movements are restricted to $R^2$, any additional dimensions
are unneeded.

### $H_0 = 0$

Additionally, we insist (I believe uncontroversially) that the trail be connected.
This notion is equivalent to insisting it have no 0 dimensional holes, i.e. 
it belongs to the homology group: $H_0=0$. While possible to reformulate the
problem with disconnected components, given the bounding envelope restriction to 
come they shall prove irrelevant and unreachable.

### Trail must be bounded (or effectively bounded[^5])

While an unbounded region in $R^2$ may admit configurations that halt, we shall
insist that a trail be bounded. This allows us to reason about tactics for
exhausting the search space in a bounded amount of time.

### 1-d and k-d holes

Note that by the homology groups of examples 2 and 3 are exactly the same.
That is to say, they are both connected and have $H_1 = 1$ and are thus in
the same homology of a circle. In some sense both paths are perfectly valid,
but one may assert that example 3 affords a "shortcut" because it fails to 
visit the loop. Here, such distinctions will be largely ignored due to their
ill defined nature. In summary $H_0 =0, H_1 = N, H_{k>1} = 0$ where $N\in \mathbb{N}$


### Area of the $\mathcal{T} \neq 0$

While, perhaps not strictly required, to match physical intuitions any 
segment must have non zero area. (i.e. no finitely thin line-segments)

## HIT/MISS/GOAL and the Robot Set $\mathcal{R}_t$ ##

Let us define the set of points enclosed by the robot at time $t$ as
$\mathcal{R}_t = (x - x_r)^2 + (y - y_r)^2 \leq r^2$. In the robot set the is
always a point (which move with the robot) $p_s = (x_s, y_s) \in \mathcal{R}_t$
that corresponds to the sensor location.

We then define the value of the sensor as:

- GOAL iff $p_s \in \mathcal{G}$
- MISS iff $p_s \notin \mathcal{T}$
- HIT iff $p_s \in \bar{\mathcal{G}} \cap \mathcal{T}$

Note that these events are mutually exclusive by construction.

# Invariant 1: $\mathcal{T} \cap \mathcal{R}_t \neq \emptyset \implies \mathcal{T} \cap \mathcal{R}_{t+dt} \neq \emptyset$

## Necessary restrictions on maximum velocity ##

Observe that the robot travels a distance, $D(\mathbf{v})$, before stopping. 
Thus, if $D(\mathbf{v}) = \int_0^T \mathbf{v}(t) dt > 2 r$ then the time 
between detecting a MISS and stopping may result in $\mathcal{T} \cap
\mathcal{R}_{t+T} = \emptyset$ provided the trail doesn't happen to curve back
s.t. it jumps between trail segments.

T can be computed by solving for $t$ in $\dot{x}(t) = \dot{y}(t) = 0$. 
Recalling the relevant stop state dynamics and differentiating yields:

> $\dot{x}(t) = -e^{-\gamma t} \dot{x}(0)$

> $\dot{y}(t) = -e^{-\gamma t} \dot{y}(0)$

Here we see an exponential decay in velocity, $\ldots$.... but, that takes an
infinite time to get to 0![^10]

At this point we have a few options, 2 are given:

1. We can add a small constant friction force the dynamics (yuck)
2. Use $\dot{x} = \xi'$
    - $T = \min(\log({\frac{\xi'}{\dot{x}(0)}})/ \gamma, \log({\frac{\xi'}{\dot{y}(0)}})/ \gamma)$
3. Abandon quiescent conditions between stop and drive/turn.

Both modifications present their own issues. Here we shall consider the 2nd if only because it 
integrates better with current work[^14]. We will work under the assumption that $\dot{x} = \xi'$ 
instantaneously results in $\dot{x} = 0$. In practice, such an approximation should be harmless.

Finally, we note that $D(\mathbf{v}) = \int_0^T \mathbf{v}(t) dt > 2 r$ uniquely defines
a $v_{max}$. Returning to the drive dynamics (and similarly turn dynamics)

> $\dot{x}(t) = C_2 \gamma (-e^{-\gamma t} + 1)$

Thus, $v_{max} = (\frac{F_0}{m})\gamma^{-1}$.[^11]

Solving for $F_0$ yields

> $F_{max} = m \gamma v_{max}$

## Development of envelope based on maximum velocity ##

To avoid the robot moving between trail segments by overshooting the boundary, valid trails
shall be further restricted with an envelope. The formal statement is: 2 points in $\delta \mathcal{T}$
enclosed by disjoint bounding spheres with radius $D(v_{max})$ (i.e. different neighborhoods) are at minimum
a distance $D(v_{max})$ apart.

### Overshoot angle: $\Phi$

In the exact same procedure as defining $D$, we define $\Phi$ as the stopping angle in the turn state.
The restriction in this case is that $\Phi < \pi$, but much tighter bounds may be sought. 

We again will run into an infinite amount of stopping time, requiring the same approximation as before.
Here we us $\dot{\theta} = \xi$ as the cut off point. This then defines $\Delta$ and $\epsilon$ in the 
dynamics (where $\epsilon$ accounts for the approximation of non-instantaneous starting and stopping).

# Solutions for General Trails #

This section is mainly included for completeness. The main goal is to convince the reader
that while general solutions exist, they are relatively impractical and/or probabilistic.

## Dynamical Billiards

![http://en.wikipedia.org/wiki/File:BunimovichStadium.svg](images/BunimovichStadium.png)

Dynamical Billiards [@hbilliards] [@elastic] [@chaos] is the study of a generalized billiards game
with arbitrary boundaries. It is included here mostly for completeness, and because its literature 
offers some insight into solving the general trail problem. In the billiard problem, the ball undergoes
 specular reflection on the boundary[^12]. It is one of the first examples of a completely 
deterministic system with chaotic behavior. That is, the system is exponentially unstable with
respect to perturbations in the initial conditions. 

More over, the spectral reflection isn't even necessary for this to be the case! Because our system
always overshoots the boundary (i.e. the reflection angle never approached $\pi$), then our robot will experience the _same_ behavior! That's really to bad for 2 reasons:

1. Any simulation approximating the derived equations of motion will blow up (in the general case)[^13]
2. Perturbations to the model (such as generalizing to rectangular automata with forces in some interval) also
results in instability.

Nevertheless, abandoning any notion of understanding deviations from the model let us quickly overview (albeit hand wavily) 2 schemes the with some caveats _will_ result in the automata reaching the goal state.

## $\Phi = c \pi$, $c \notin \mathbf{Q}$

If we restrict the overshooting angle, $\Phi$, to irrational multiples of $\pi$ we produce an aperiodic orbit. _If_
the dense orbit and the goal state have a non empty intersection, then the robot will halt in a finite
amount of time.

## $\Phi \in [0, \pi/2]$

Given a uniformly random choice of $\Phi$, a similar result to the aperiodic orbit occurs, now with the probability of a finite search time limiting to 1.

Both results are however impractical as they give no bounds on time required. Furthermore, while possible to produce
$\Phi$ arbitrary close to an irrational multiple of $\pi$, it must inevitably be an approximation. As for the random choice of $\Phi$, simulating might be done with the rectangular version of the forcing previously described. While in principle possible to arbitrary precision, the chaotic nature of the problem suggests that any non trivial trail may
be computationally unfeasible.

# Practical limits in $\gamma$ and boundary following

Upon first encounter with the problem, many of my colleagues (and myself) initially 
imagine the robot following along the boundary. While possible with more advanced sensor
systems (or equivalently memory), the memoryless single sensor case affords no such solution.

That said, it is clear that if the automata had near instantaneous (implying arbitrarily large $\gamma$),
 and the curvature of the boundary was restricted (say either zero or negative) then it is possible for the automata to maintain the following inductive invariant:

Given the min distance to the boundary $d_i = \min(\{\text{dist}((x(t_i),y(t_i)), (x_b - y_b)) | \forall(x_b, y_b) \in \delta \mathcal{T}\})$

> $d_i < \Xi \implies d_j < \Xi$, where $t_i < t_j$

Provided such an invariant held true (which holds for many practical $\gamma$ and trails) and provided the
minimum width of the trail is less than $\Xi$, then if the goal lies on the same boundary that the robot is 
following then the goal will be found in a finite amount of time. $\square$

## Caveat on increasing $\gamma$

Increasing $\gamma$ while maintaining $v_{max}$ necessarily implies increasing $F_0$ (See sections on dynamics and stopping distance).
However, the model develop fails to consider internal shears and stresses on the robot. As $F_0$ increases, these effects become
less negligible. In fact, intense shears and stresses may result in the robot's frame deforming or more likely breaking. The 
exact limits are outside of the scope of this paper.

# Restricted Trails

Another example is that of a parametric line[^15], $l(\tau), \tau \in [0, 1]$, bloated by a 
constant width with the $H_{n \geq 0} = 0$.

This enforces a smooth constant width trail with no self intersections. Thus, the parameter $\tau$ provides a constant metric for progress.

Specifically, we use the point $\tau^*$ on line $l$ that is closest to $x, y$ as our metric. If $\tau^*$ is shown to be monotonically increasing, that implies the robot will reach the goal state in a finite amount of time.

Given the curvature of the line, there need exist some $\Phi_{max} \leq \pi/2$ s.t. the robot having $\Phi < \Phi_{max}$ guarantees the previous invariant. 

To illustrate this, first consider the limits of no curvature and the limit to $\pm$ infinite curvature. Given no curvature in the line, $\Phi_{max} = \pi/2$, which is to say the robot does no turn around. Given that the robot has non zero velocity, it _must_ advance implying $\tau^*_2 \geq \tau^*_1$. In the limits to $\pm$ infinite curvature, we arrive at a contradiction. The line must turn back on itself, but there are no self intersections allowed. Thus, the curvature is finite.

We consider instead the positive and negative curvature cases

1. For negative curvature
    1. The nearest boundary is turning towards the robot.
    2. Thus, the far boundary is turning away from the robot. (because of constant width)
    3. Therefore, the normal line from the boundary (i.e. having $\Phi = \pi/2$) will result
    in intersecting the far boundary at a $\tau < \tau^*$ (with $\Phi > \pi/2$ only making the 
    problem worse).
    4. Thus, $\Phi_{max}$ decreases.

2. Similarly, for positive curvature
    1. The nearest boundary is turning away from the robot.
    2. Thus, the far boundary is turning towards the robot.
    3. Therefore, the normal line from the boundary will result
    in intersecting the far boundary at a $\tau > \tau^*$
    4. Thus, $\Phi_{max}$ may increase or stay the same.

Thus, one must pick the $\Phi_{max}$ based on the largest (in magnitude) negative curvature and width
of the trail.

$\square$

# Worked Example: Straight line case #

![](images/example_execution.png ) 

Let us work out explicitly the most trivial case (that of a straight) trail.

1. As previously proved, $\Phi_{max} = \pi_2$.

2. We will model the boundaries of the trail as $(L, R, U, D) = (x=0, x=2, y=1, y=0)$

3. Thus, we may expect an execution as illustrated in diagram 7.
    1. Note that the initial angle is different the other two.
    2. While the initial angle is arbitrary, given that the robot reaches a steady state (building up max 
    Kinetic Energy) before encountering the boundary when turning, the robot will always overshoot by $\Phi$
    degrees.
    3. Because $\Phi < \Phi_{max}$, $tau^*$ will be monotonically increasing (as illustrated)
    4. Thus, the boundary will be reached in a finite amount of time. $\square$

# Conclusion

The work presented here formally defines the hybrid automata for a memoryless single sensor automata.
This includes the dynamics, technicalities in design of the hybrid automata, trail definitions, and numerous
properties and invariants that restrict the forcing, friction, and classes of trails.
Both a partial solution for general trails and a complete solution for the restricted trails have been 
worked out.

# Future work
## Physical Implementation

While outside of the current scope of the project, the initial intention was to develop
physical implementations of the robots, estimate $\gamma$, determine what kind
of trails are valid using the developed theory, and actually test how well the model holds.

In addition, the initial proposal's implementation called for an Arduino Haskell DSL, which
is an interesting verification problem in itself.

## External Guidance

While HIT/MISS corresponded to fixed functions in the developed theory, in principle an external
controller could use the HIT/MISS actions to guide the robot. HITs would indicate continue, or stop turning
depending on the context. Similarly, MISS would indicate stop and start turning. A successive HIT/MISS
sequence during the turning state could be used to control the initial turning direction.

## Perturbations from $\mathbf{F_0}$

Alluded to in the dynamical billiards section, rectangular automata could be used to model stochastic
perturbations in forcing. Also, mentioned in the dynamical billiards section is the instability of such a 
procedure. Perhaps some form of abstraction on certain sub-classes of trails could avoid this issue.
Specifically, trails with convergent solutions such an elliptical boundary that focuses trajectories
towards the goal.

## Analysis of 2 sensor case + comparisons

There exists a HUGE literature to explore for richer multi sensor systems. It would be interesting (although exhausting) to do a comprehensive review of the memoryless 2 sensor models and their various advantages over the simple single sensor case.

## More in depth general trails

The depth and analysis of the general trails is much more limited than this author would like.
The primary limitation is a deep understanding of the more subtle topological arguments
likely required to properly study the problem.

## Allow non zero potential fields

The above analysis perhaps unfairly specializes to flat terrain (and thus no interesting potential fields). Extension to arbitrary terrains seems impossible, but validation of arbitrary terrains with no prior domain experience may be possible with simulation based verification systems such as C2E2.

# References

[^1]: We may choose later to model more complex mass densities or potentials, but for now this suffices.

[^4]: with the caveat that $z(x, y)$ __must__ be such that it provides a sufficient local minimum to bring $|\mathbf{v}|=0$ in an envelope around the trail satisfying invariant #1 (i.e. robot doesn't "leave" the trail)

[^5]: Given a goal region that partitions a path into a finite and infinite pair, the finite component can be considered effectively bounded.

[^6]: Here is an example of an intro to robotics lesson. https://www.cs.duke.edu/robocup/lessons/2007/1101.pdf

[^7]: Such as moving along with the boundary.

[^8]: if it does over rotate, that implies violation in properties about the trail which such as non-zero area and a bounding envelope developed later.

[^10]: Hey look! A zeno like paradox, although I think the execution itself is admissible since its infinite duration, but finite transitions (in that the transition never occurs if we're not careful)

[^11]: The $\cos{\theta}$ gets dropped w.l.o.g by realigning the axis s.t. $\theta=0$

[^12]: As may be alluded in the name specular, this is also a well studied optics problem (and a constant headache for ray tracing graphics engines)

[^13]: Looking at you c2e2

[^14]: And I don't have the time... the 3rd option is in fact the best option as it still yields exact analytic solutions.

[^15]: Yes line...not trail... or path
