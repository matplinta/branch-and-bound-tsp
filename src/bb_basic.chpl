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
    }
}

proc main() {

    // READ TSPLIB DATA
    var adj = tsplib_reader(file, N);

    // INIT VARIABLES
    var root =  if initRoot == -1 then random(1,N) else initRoot;
    var minArray: [1..N] real;
    var minPathArray: [1..N] list(int);
    minArray[root] = MAX_INTEGER;
    var localMin: real = MAX_INTEGER;
    var path, localMinPath: list(int);
    var ranges: [1..#split] list(int);
    path.append(root);

    // INIT RANGES ARRAY
    var i = 0;
    for branch in 1..N do {
        if branch == root { continue;}
        ranges[branch % split + 1].append(branch);
    } 

    writeln("INF: ranges array:\t", ranges);

    timer.start();
    
    coforall process in 1..split with (in path, in localMin, in localMinPath) do {
        for node in ranges[process] {
            var distance = adj(root, node): real;
            path.append(node);
            tree_branch(distance, adj, path, localMin, localMinPath);
            minArray[node] = localMin;
            minPathArray[node] = localMinPath;
            path.pop();
        }
        writeln("INF: ", process, " process exited. Local min of the process: ", localMin);
    }
    
    timer.stop();

    var (minVal, minLoc) = minloc reduce zip(minArray, minArray.domain);
    writeln("INF: Global best path:\t", minPathArray[minLoc]);
    writeln(root, ",", minVal, ",", timer.elapsed());
}

