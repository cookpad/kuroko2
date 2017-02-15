## v0.3.3

- Allow user to receive notification [#39](https://github.com/cookpad/kuroko2/pull/39)

## v0.3.2

- Change kuroko script formatter to rails helper and expand definition name if needed [#37](https://github.com/cookpad/kuroko2/pull/37)
- To simplify slack messages [#36](https://github.com/cookpad/kuroko2/pull/36)
- Link to docs/index.md [#35](https://github.com/cookpad/kuroko2/pull/35)
- Refactor configurations [#34](https://github.com/cookpad/kuroko2/pull/34)
- Make use content_for method [#33](https://github.com/cookpad/kuroko2/pull/33)
- Kill n+1 queries [#32](https://github.com/cookpad/kuroko2/pull/32)
- Add foreman to development dependency gem list [#30](https://github.com/cookpad/kuroko2/pull/30)
- Add confirmation dialog when to cancel failed job instance [#29](https://github.com/cookpad/kuroko2/pull/29)

## v0.3.1

- Do not include `job_instances` [#28](https://github.com/cookpad/kuroko2/pull/28)

## v0.3.0

- To skippable waiting tokens [#27](https://github.com/cookpad/kuroko2/pull/27)
- Remove mysql2 from runtime dependency [#26](https://github.com/cookpad/kuroko2/pull/26)
- Job instance logs should be ordered [#25](https://github.com/cookpad/kuroko2/pull/25)
- Kill n+1 queries and fix tag links [#22](https://github.com/cookpad/kuroko2/pull/22)
- Display tags [#21](https://github.com/cookpad/kuroko2/pull/21)
- Support webhook notification [#16](https://github.com/cookpad/kuroko2/pull/16)
- Display seconds in Logs/Execution Logs timestamp [#18](https://github.com/cookpad/kuroko2/pull/18)
- Always define end_time for job limelines [#17](https://github.com/cookpad/kuroko2/pull/17)
- Fix sub_process task linker [#15](https://github.com/cookpad/kuroko2/pull/15)
- Change `Notify success event to Slack/Hipchat` option to `Notify all event to Slack/Hipchat` [#8](https://github.com/cookpad/kuroko2/pull/8) [#19](https://github.com/cookpad/kuroko2/pull/19)
- Add example systemd unit files [#14](https://github.com/cookpad/kuroko2/pull/14)
- Convert scheduled times into AS::TimeWithZone [#13](https://github.com/cookpad/kuroko2/pull/13)
- Fix queue validation [#12](https://github.com/cookpad/kuroko2/pull/12)
- Add users_controller#edit [#9](https://github.com/cookpad/kuroko2/pull/9)

## v0.2.3
- Fix Kuroko2::JobDefinition.search_by [#11](https://github.com/cookpad/kuroko2/pull/11)
- Validate hd parameter if configured [#10](https://github.com/cookpad/kuroko2/pull/10)

## v0.2.2
- s/Time.now/Time.current/ [#4](https://github.com/cookpad/kuroko2/pull/4)
- Splitting the autoload directory [#5](https://github.com/cookpad/kuroko2/pull/5)
- Add documentations [#6](https://github.com/cookpad/kuroko2/pull/6)
- Fix loading Kuroko2.logger [#7](https://github.com/cookpad/kuroko2/pull/7)

## v0.2.1
- Eager load kuroko2 lib directory [#2](https://github.com/cookpad/kuroko2/pull/2)
- Use utf8mb4 as default in database.yml [#3](https://github.com/cookpad/kuroko2/pull/3)

## v0.2.0
- Initial OSS version
