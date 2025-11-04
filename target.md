请基于polars库使用Rust处理时间序列数据，默认第一列为时间列，其列名可能为DateTime、tagTime等。
其余列为特征列。

这个库的目标是供python调用，使用uv包管理器，uv add maturin --dev， uv run maturin develop进行开发。

请搜索网络中的pyo3最佳实践，整理一个合理的项目架构，梳理常用的时间序列处理功能并进行分类实现，然后可以通过一个toml配置文件配置时序处理管道，然后通过python调用rust函数进行处理。

此外，你需要学习polars 1.35版本以后的处理方法，将运行时和python库分离开来，确保在任何平台都能够能正常运行。此外，学习polars的项目结构，重新构建当前项目的文件夹结构，并确保在python库中有相应的pyi文件以满足typing需要