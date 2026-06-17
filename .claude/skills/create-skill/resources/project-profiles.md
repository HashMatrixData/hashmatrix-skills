# HashMatrix 项目档案

> 各 Skill 的 `resources/<project>.md` 以本表的**项目键**命名。各子项目**技术选型仍在逐个讨论**，下表中「待定」项随选型落地后更新。
> 追踪平台统一为 **GitHub Issues**（`HashMatrixData/<repo>`）。

| 项目键 | 仓库 | 定位 | 语言/框架（规划） | 状态 |
|--------|------|------|------------------|------|
| `webui` | hashmatrix-webui | 接入层前端：WebUI / 数据大屏 / 可视化编排 | TS（Next.js / Vue3 待定） | 脚手架 |
| `gateway` | hashmatrix-gateway | 南北向网关：路由/限流/鉴权(OIDC)/审计 | APISIX 或 Spring Cloud Gateway 待定 | 脚手架 |
| `governance` | hashmatrix-governance | 数据治理：元数据/专题-主题-实体三层模型/质量 | Java（Spring Boot） | 脚手架 |
| `security` | hashmatrix-security | 数据安全：分类分级/标签/审批/审计/资源监控 | Java（Spring Boot + Flowable） | 脚手架 |
| `tools-bi` | hashmatrix-tools-bi | 数据工具：报表BI/自助分析/可视化编排 | Java/TS（BI 组件待定） | 脚手架 |
| `privacy` | hashmatrix-privacy | 隐私计算：MPC/PSI/匿踪/节点互联 | Python + Java | 脚手架 |
| `data-foundation` | hashmatrix-data-foundation | 数据基础：流批采集/湖仓/统一计算/向量/Connector SPI | Java + Flink | 脚手架 |
| `platform-common` | hashmatrix-platform-common | 平台公共：调度/工作流/统一认证/元数据 | Java | 脚手架 |

## 通用约定（跨项目）

- **公共能力复用**：主仓 `hashmatrix` 提供 `libs-java` / `libs-ts`（公共依赖）、`contracts`（ICD 接口契约）。新代码优先复用，不重复造轮子。
- **部署**：Kubernetes + Helm（umbrella chart）；服务发现走 K8s Service/DNS（不引 Nacos 注册）。
- **信创双轨**：平台自身用开源；外部数据源接入走 Connector SPI（达梦/人大金仓等插件化）。
- **架构背景**：详见主仓 `docs/architecture/`。

## 给 Skill 资源作者的提示

- 写 `resources/<project>.md` 时，只记录**该项目相对通用流程的差异**（架构检查点、类型/测试约定、条件维度、验证命令）。
- 技术未定的部分，先写「待定」占位，不要臆造框架细节。
- 不得写入任何客户可识别信息、真实主机 IP、凭据。
