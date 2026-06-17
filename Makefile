.PHONY: validate

# 校验插件 JSON 清单与 .mcp.json 格式是否合法
validate:
	@for f in .claude-plugin/marketplace.json .claude-plugin/plugin.json .mcp.json; do \
		python3 -c "import json,sys; json.load(open('$$f')); print('ok  '+'$$f')" || exit 1; \
	done
	@echo "所有清单 JSON 合法 ✅"
