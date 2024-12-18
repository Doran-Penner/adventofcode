use aoc_runner_derive::aoc;

#[derive(Debug)]
enum Object {
    Wall,
    Unvisited,
    Visited,
}

#[derive(Debug)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

#[derive(Debug)]
enum StepResult {
    Exit,
    Stay,
}

use Direction::*;
use Object::*;
use StepResult::*;

struct World {
    room: Vec<Vec<Object>>,
    width: i32,
    height: i32,
    guard_pos: (i32, i32),
    guard_dir: Direction,
}

impl World {
    pub fn from(input: &str) -> Self {
        let room = Vec::from_iter(input.split_whitespace().map(|line| {
            Vec::from_iter(line.chars().map(|char| match char {
                '#' => Wall,
                '.' => Unvisited,
                '^' => Visited,
                other => panic!(
                    "Unexpected character in input: '{}' is not one of '#', '.', '^'",
                    other
                ),
            }))
        }));
        let width: i32 = room.len() as i32;
        let height: i32 = room[0].len() as i32;
        let guard_idx = input.chars().position(|char| char == '^').unwrap() as i32;
        let guard_pos = (guard_idx % (width + 1), guard_idx / (width + 1));
        let guard_dir = Up;
        World {
            room,
            width,
            height,
            guard_pos,
            guard_dir,
        }
    }

    fn get_at(&self, idx: (i32, i32)) -> Option<&Object> {
        let (x, y) = idx;
        if 0 <= x && x < self.width && 0 <= y && y < self.height {
            Some(&self.room[y as usize][x as usize])
        } else {
            None
        }
    }

    fn set_at(&mut self, idx: (i32, i32), obj: Object) {
        let (x, y) = idx;
        self.room[y as usize][x as usize] = obj;
    }

    pub fn total_visited(&self) -> i32 {
        self.room.iter().flatten().fold(0, |acc, obj| match obj {
            Visited => acc + 1,
            _ => acc,
        })
    }

    pub fn step(&mut self) -> StepResult {
        let target = dir_step(&self.guard_pos, &self.guard_dir);
        match self.get_at(target) {
            None => Exit,
            Some(obj) => {
                match obj {
                    Wall => {
                        self.guard_dir = turn(&self.guard_dir);
                    }
                    Unvisited => {
                        self.set_at(target, Visited);
                        self.guard_pos = target;
                    }
                    Visited => {
                        self.guard_pos = target;
                    }
                };
                Stay
            }
        }
    }
}

fn dir_step(loc: &(i32, i32), dir: &Direction) -> (i32, i32) {
    let (x, y) = loc;
    match dir {
        Up => (*x, y - 1),
        Down => (*x, y + 1),
        Right => (x + 1, *y),
        Left => (x - 1, *y),
    }
}

fn turn(dir: &Direction) -> Direction {
    match dir {
        Up => Right,
        Right => Down,
        Down => Left,
        Left => Up,
    }
}

#[aoc(day6, part1)]
fn part1(input: &str) -> i32 {
    let mut world = World::from(input);
    loop {
        let status = world.step();
        if let Exit = status {
            break;
        }
    }
    world.total_visited()
}

// #[aoc(day06, part2)]
// fn part2(input: &str) -> String {
//     todo!()
// }

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part1_example() {
        let ex_in = "....#.....\n\
                     .........#\n\
                     ..........\n\
                     ..#.......\n\
                     .......#..\n\
                     ..........\n\
                     .#..^.....\n\
                     ........#.\n\
                     #.........\n\
                     ......#...";
        assert_eq!(part1(ex_in), 41);
    }

    // #[test]
    // fn part2_example() {
    //     assert_eq!(part2("<EXAMPLE>"), "<RESULT>");
    // }
}
