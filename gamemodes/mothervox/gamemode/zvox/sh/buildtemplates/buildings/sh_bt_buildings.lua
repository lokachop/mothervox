ZVox = ZVox or {}

function ZVox.MV_LoadBuildingTemplates()
	local univ = ZVox.GetUniverseByName("mothervox")

	-- part / item shop
	ZVox.LoadBuildTemplate(univ, {
		["x"] = 20,
		["y"] = 15,
		["z"] = 992,
		["airIgnore"] = false,
	},"XQAAAQC1DQAAAAAAAAAhFQW9du4EwgcZh4qBZbva4WHHtamq0JLhc8u4tgiIlxB5T8ZCBltxSMSmAy7JetlPtRATSSQ1T28+nzcpKDerfZ7w6ibhV33YKQ4VuIP4mqeTwVluQkc2R9ksbX0s6ZJDtVH5StPtHL7kNlPYNyOddnbRC8mgZSPViqlP5a8Ty9BJ/XQ2qhmX+DWcXT5NXlGbnuwf2Y8N/t1aCLHgZskCM391yyfLJRCbiKsudE2s37RDjGri6FHYm6Kq+yb/LqvBuB095WCdCJNpgpeNBUgQ4sjsHe3I2NBX0VFaceP4KMIoLoEPvOsU76Kc4cXFgtTJBqUMo2BVw+2VQCpwynqTXrX3Tf9MHg1TQg8til3kBP1CP6SGFIdAfb1r+5HlY49GK81aUawlrH/x5i/+IImkEZf4IM1lvTUMgoS4L959tC8S1GmUF+IX9h1ZdV19BfoRIhHgs6Wfaa91GQsw882JMTBZuvD9thiIX+1xh+jB8i80wdynm2PVSk5kwTYNY0x9LCOpA5+94XK57mLkuJpRcxic2v7R5QA=")

	-- ore shop
	ZVox.LoadBuildTemplate(univ, {
		["x"] = 3,
		["y"] = 24,
		["z"] = 992,
		["airIgnore"] = false,
	}, "XQAAAQDRBAAAAAAAAAAhFQW9ds7fFSA0H47L2hbkMUdpARSN6uouyTkMRH6swOLpaEJLalBjIeh9bPzUt5hPTAcfpwg/yZ8AyZxcUWe+w/WL45N1C8U6pA7/ETn3xzsUUOw6eFt9I0dt51hDFHbFZY0U+5+7WsDUGJEn9nUbG3Zo15mA4tvfG2MxoLEuGMSyNub2LJ8B6Tv82ivCIKv4NDlWyT9KF3dlk72b2tbOj2Rq8PzLNNNpGoJQkat6NvDRLHhBnQ+JgzefDeHD3o8eAA==")


	-- fuel shop
	ZVox.LoadBuildTemplate(univ, {
		["x"] = 1,
		["y"] = 1,
		["z"] = 992,
		["airIgnore"] = false,
	}, "XQAAAQC+CgAAAAAAAAAhFQW9duOhG0ygi4NLQ5d6ejbk1bSjKO/CWVe0sPOEjOWPLtEcgooZJrDUPYAq47o/Fd62HwM0Sgl4sNwJfDzVQ9mw1/HGhygHQfmTbHGolzIjOTP0LAG4uGr7Mx16ZZuLuc+d3t04PnxUgMAja/j2bxzh0J3yUiCGX2snaLl18F9mUmkKJEIrs3H98T4Hql61ztdJaoAdrEjoFGuuFBCbGmdAxajv1lHJPcPQ5rkzLnNZsMA/RnH0Zk4JC490o8LkRDWIIuVafYWR/zQSaPphWXuTzjApkN1n2ym8fgNq01PHumAnw19TfNqhyf7G8EeYQXx091VMC/B+v5lTgFfDlkJfCnBFG2rTLBhqq/mbg3rtbialMpdE/xiWF82hyHuSq9PRgLrEMX10uoI+vBxrOT3+gtikrA/C9AMKJeE/Wj9scjDVb1y+")

	-- facility
	ZVox.LoadBuildTemplate(univ, {
		["x"] = 4,
		["y"] = 3,
		["z"] = 1,
		["airIgnore"] = false,
	}, "XQAAAQABCwAAAAAAAAAhFQW9dwLGwgZNPKqKmTjvgRnv93Q1kvANPECAFQGD3WbaMrXk2I6xJnhkZ8jxycyuNvgEdzXJJeBnFjD7T1RL6vCGU04o8IFQAyNLFFPVexgZyTG67AD3RKW7Uv3W4X4jBKuEbsUYHxcMRD2gmynrnvWYpebQ2FMocIVqDCLgUWHu5n58yeutHoTERwcSDNeItp/LpYW4IT9dd/+ScAlt2woFYTBgX8e7Bf3SmQlpos7RnwZXJ0/AYNVUbCQ6avets+yfmC+DMGBk8j2vx9heGoX1M0u/8v1XwYsvYnPI6E6hSkIowFhQK4djWVXBKSB1BtnoQ/0Mr9phzv4t4RE8j+c80CGtQAwhgVpAvf385CFiUwiH52TdPmo/i7VxYoyeYSeF1G52oou4nFRoH2rdhuzUxpP4BfsHdm/XX2C2tqSg6aVDs/mVcaIAhnpHHikmvRHxtI8QcUPSJ6EG7KJ8D8lScsNBIbqOAAA=")
end