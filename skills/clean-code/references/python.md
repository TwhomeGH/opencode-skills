# Python — Docstrings

PEP 257 定義基本格式；三種主流風格：**Google**、**NumPy**、**reST（Sphinx）**。沿用專案既有風格，不要混用。

## 基本規則（PEP 257）

- 使用 `"""..."""`。
- 單行：摘要與引號同行，句尾加句點。
- 多行：摘要行 → 空行 → 正文 → 收尾 `"""` 自成一行。
- docstring 是模組 / 函式 / 類別的第一個 statement。

## Google 風格（最常見）

```python
def divide(a, b):
    """計算 a 除以 b。

    Args:
        a: 被除數。
        b: 除數，不可為 0。

    Returns:
        商。

    Raises:
        ZeroDivisionError: 當 b 為 0。
    """
```

## NumPy 風格

```python
def divide(a, b):
    """計算 a 除以 b。

    Parameters
    ----------
    a : float
        被除數。
    b : float
        除數。

    Returns
    -------
    float
        商。
    """
```

## reST / Sphinx 風格

```python
def divide(a, b):
    """計算 a 除以 b。

    :param a: 被除數。
    :param b: 除數。
    :returns: 商。
    :raises ZeroDivisionError: 當 b 為 0。
    """
```

## 官方

- [PEP 257](https://peps.python.org/pep-0257/)
- [Google Style](https://google.github.io/styleguide/pyguide.html#38-comments-and-docstrings)
- [NumPy](https://numpydoc.readthedocs.io/en/latest/format.html)
