use aoc_runner_derive::{aoc, aoc_generator};

// have to return Vecs bc the macro doesn't like returning `impl...`
// also seems like everything is natural so we're just gonna use unsigned ints
#[aoc_generator(day7)]
fn parse(input: &str) -> Vec<(u64, Vec<u64>)> {
    // we'll just panic on parse errors
    input
        .lines()
        .map(|line| {
            let (target, nums) = line.split_once(':').expect("Encountered colon-less line");
            let parsed_target: u64 = target.parse().expect("Failed to parse number");
            let parsed_nums: Vec<u64> = nums
                .split_whitespace()
                .map(|num_as_str| num_as_str.parse().expect("Failed to parse number"))
                .collect();
            (parsed_target, parsed_nums)
        })
        .collect()
}

fn makes_target(target: &u64, acc: u64, nums: &Vec<u64>, nums_idx: usize) -> bool {
    match nums.get(nums_idx) {
        None => target == &acc,
        Some(num) => {
            // WAHOO we love recursion
            makes_target(target, acc + num, nums, nums_idx + 1)
                || makes_target(target, acc * num, nums, nums_idx + 1)
        }
    }
}

#[aoc(day7, part1)]
fn part1(input: &[(u64, Vec<u64>)]) -> u64 {
    input
        .iter()
        .filter(|(target, nums)| makes_target(target, nums[0], nums, 1))
        .map(|(target, _)| target)
        .sum()
}

fn num_concat(first: u64, second: &u64) -> u64 {
    match second.checked_ilog10() {
        // hope we don't get negatives or this is senseless
        None => first * 10,
        Some(digits_minus_one) => first * 10u64.pow(digits_minus_one + 1) + second,
    }
}

fn makes_target_with_concat(target: &u64, acc: u64, nums: &Vec<u64>, nums_idx: usize) -> bool {
    match nums.get(nums_idx) {
        None => target == &acc,
        Some(num) => {
            // friendly reminder! when copying a recursive function...
            // make sure to rename the recursive calls too
            makes_target_with_concat(target, acc + num, nums, nums_idx + 1)
                || makes_target_with_concat(target, acc * num, nums, nums_idx + 1)
                || makes_target_with_concat(target, num_concat(acc, num), nums, nums_idx + 1)
        }
    }
}

#[aoc(day7, part2)]
fn part2(input: &[(u64, Vec<u64>)]) -> u64 {
    // exact* same thing!
    input
        .iter()
        .filter(|(target, nums)| makes_target_with_concat(target, nums[0], nums, 1))
        .map(|(target, _)| target)
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "190: 10 19\n\
                           3267: 81 40 27\n\
                           83: 17 5\n\
                           156: 15 6\n\
                           7290: 6 8 6 15\n\
                           161011: 16 10 13\n\
                           192: 17 8 14\n\
                           21037: 9 7 18 13\n\
                           292: 11 6 16 20";

    #[test]
    fn parse_example() {
        let target = vec![
            (190, vec![10, 19]),
            (3267, vec![81, 40, 27]),
            (83, vec![17, 5]),
            (156, vec![15, 6]),
            (7290, vec![6, 8, 6, 15]),
            (161011, vec![16, 10, 13]),
            (192, vec![17, 8, 14]),
            (21037, vec![9, 7, 18, 13]),
            (292, vec![11, 6, 16, 20]),
        ];
        assert_eq!(parse(EXAMPLE), target);
    }

    #[test]
    fn part1_example() {
        assert_eq!(part1(&parse(EXAMPLE)), 3749);
    }

    #[test]
    fn numconcat_basic() {
        assert_eq!(num_concat(4, &9), 49);
        assert_eq!(num_concat(4, &56), 456);
        assert_eq!(num_concat(4, &10), 410);
        assert_eq!(num_concat(9, &10), 910);
        assert_eq!(num_concat(9, &9), 99);
        assert_eq!(num_concat(9, &56), 956);
        assert_eq!(num_concat(10, &10), 1010);
        assert_eq!(num_concat(10, &9), 109);
        assert_eq!(num_concat(10, &56), 1056);
        assert_eq!(num_concat(11, &10), 1110);
        assert_eq!(num_concat(11, &9), 119);
        assert_eq!(num_concat(11, &56), 1156);
    }

    #[test]
    fn numconcat_examples() {
        assert_eq!(num_concat(15, &6), 156);
        assert_eq!(num_concat(48, &6), 486);
        assert_eq!(num_concat(17, &8), 178);
    }

    #[test]
    fn part2_failure() {
        let inp = (7290, vec![6, 8, 6, 15]);
        let out = makes_target_with_concat(&inp.0, inp.1[0], &inp.1, 1);
        assert!(out); // should be true >:(
    }

    #[test]
    fn part2_example() {
        assert_eq!(part2(&parse(EXAMPLE)), 11387);
    }
}
