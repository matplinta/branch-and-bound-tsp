use Time;
use IO;
use Math;
use List;
use Random;

config const initRoot = -1;
config const N = 280; 
config const file = "data/a280.tsp"; 
config const split = 1;
const MAX_INTEGER = 999999999;

var timer: Timer;
// var localMin: real = 99999999999;
// var localMinPath: list(int);
// here.maxTaskPar;

proc random(min: int, max: int): int{
    var rands: [1..1] real;
    fillRandom(rands);
    var rand = 1 + rands[1] * N;
    var ret = rand: int;
    return ret;
}

proc euclidean_distance((x1, y1): 2*int, (x2, y2): 2* int): real {
    var xDistance = abs(x1 - x2);
    var yDistance = abs(y1 - y2);
    return sqrt(xDistance * xDistance + yDistance * yDistance);
}

proc tsplib_reader(path: string, n: int) : []real {
    var file = open(path, iomode.r);
    var readingChannel = file.reader();
    var nodes: [1..n] (int, int);
    var adj: [1..n, 1..n] real;

    forall i in nodes.domain {
        var node, x, y: int;
        readingChannel.readln(node, x, y);
        nodes(node) = (x, y);
    }
    file.close();

    forall (i, j) in adj.domain {
        if (i != j) {
            adj(i, j) = euclidean_distance(nodes(i), nodes(j));
            // writeln(adj(i, j));
        }
    }    
    return adj;
}

proc tree_branch(in distance: real, adj: []real, in path , inout localMin: real, inout localMinPath) {

    if (path.size == N) {
        distance += adj(path[path.size], path[1]);
        if (distance < localMin) {
            path.append(path[1]);
            localMin = distance;
            localMinPath = path;
        }
        return;
    }  

    for i in 1..N {
        if (path.contains(i)) {
            continue;
        }
        var newDistance = distance + adj(path[path.size], i);

        if (newDistance < localMin) {
            path.append(i);
            tree_branch(newDistance, adj, path, localMin, localMinPath);
            path.pop();
        } 
        // else{
        //     writeln("Branch terminated.");
        // }
    }
}

proc main() {

    var adj = tsplib_reader(file, N);
    // var adj: [1..N, 1..N] real;
    // adj(1,2) = 35;adj(2,1) = 35;adj(1,3) = 25;adj(3,1) = 25;adj(1,4) = 10;adj(4,1) = 10;adj(2,3) = 30;adj(3,2) = 30;
    // adj(2,4) = 15;adj(4,2) = 15;adj(3,4) = 20;adj(4,3) = 20;
    var root: int;
    if initRoot == -1 {
        root = random(1,N);
    } else {
        root = initRoot;
    }
    writeln("root node:\t\t", root);

    // INIT VARIABLES
    var minArray: [1..N] real;
    var minPathArray: [1..N] list(int);
    minArray[root] = MAX_INTEGER;
    var localMin: real = MAX_INTEGER;
    var path, localMinPath: list(int);
    path.append(root);

    // INIT RANGES ARRAY
    var ranges: [1..#split] list(int);
    var i = 0;
    for branch in 1..N do {
        if branch == root {
            continue;
        }
        ranges[branch % split + 1].append(branch);
    } 
    writeln("ranges array:\t", ranges);

    timer.start();
    
    coforall process in 1..split with (in path, in localMin, in localMinPath) do {
        for node in ranges[process] {
            var distance = adj(root, node): real;
            path.append(node);
            // writeln(node, " path: ", path);
            tree_branch(distance, adj, path, localMin, localMinPath);
            // writeln(node, " branch. Local min: ", localMin);
            minArray[node] = localMin;
            minPathArray[node] = localMinPath;
            path.pop();
        }
        
        writeln(process, " process exited. Local min of the process: ", localMin);
    }
    
    

    timer.stop();

    var (minVal, minLoc) = minloc reduce zip(minArray, minArray.domain);
    writeln("time:\t\t\t", timer.elapsed(), " s");
    writeln("global best path:\t", minPathArray[minLoc]);
    writeln("global min distance:\t", minVal);
}

