
Graphviz for type dependencies (or uml?)
- Solid for class or struct, dotted for protocol
- Composition vs inheritance difference in edges? (red for inheritance, black for normal reference)
- Cluster nodes of same module together in subgraphs
    - submodules in sub-cluster
    - edges within a module defined in cluster, between modules outside of cluster

Complexity analysis
- how many types have large numbers of dependencies
- cyclic dependency detection?
- islands based on some root set of Files or types (no incoming dependencies from a root), declare as safe to remove

Objc support (nice to have)
- swift generated interface of bridging header, analyze types available there for edges coming into swift types
- search .m/.mm files for -Swift.h imports for edges leaving swift types (references to types in generated header are not safe to delete)
- ? objc files are all roots as static dep analysis is not easy or feasible there with sourcekit
