use aoc_runner_derive::{aoc, aoc_generator};

// have to return Vecs bc the macro doesn't like returning `impl...`
#[aoc_generator(day7)]
fn parse(input: &str) -> Vec<(i64, Vec<i64>)> {
    // we'll just panic on parse errors
    input
        .lines()
        .map(|line| {
            let (target, nums) = line.split_once(':').expect("Encountered colon-less line");
            let parsed_target: i64 = target.parse().expect("Failed to parse number");
            let parsed_nums: Vec<i64> = nums
                .split_whitespace()
                .map(|num_as_str| num_as_str.parse().expect("Failed to parse number"))
                .collect();
            (parsed_target, parsed_nums)
        })
        .collect()
}

// #[aoc(day7, part1)]
// fn part1(input: &[(i64, Vec<i64>)]) -> i64 {
//     todo!()
// }

// #[aoc(day7, part2)]
// fn part2(input: &str) -> String {
//     todo!()
// }

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

    // #[test]
    // fn part1_example() {
    //     assert_eq!(part1(&parse(EXAMPLE)), 3749);
    // }

    // #[test]
    // fn part2_example() {
    //     assert_eq!(part2(&parse("<EXAMPLE>")), "<RESULT>");
    // }
}
