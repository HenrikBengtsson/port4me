from setuptools import setup

setup(name="port4me",
      version="0.0.0.9000",
      description="The 'port4me' tool: (1) finds a free TCP port in [1024,65535] that the user can open, (2) is designed to work in multi-user environments, (3), gives different users, different ports, (4) gives the user the same port over time with high probability, (5) gives different ports for different software tools, and (6) requires no configuration.",
      url="http://github.com/HenrikBengtsson/port4me",
      author="Henrik Bengtsson",
      author_email="henrikb@braju.com",
      license="MIT",
      packages=["port4me"],
      zip_safe=False)
